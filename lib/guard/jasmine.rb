require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'net/http'

module Guard

  # The Jasmine guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class Jasmine < Guard

    autoload :Formatter, 'guard/jasmine/formatter'
    autoload :Inspector, 'guard/jasmine/inspector'
    autoload :Runner, 'guard/jasmine/runner'
    autoload :Server, 'guard/jasmine/server'

    attr_accessor :last_run_failed, :last_failed_paths

    DEFAULT_OPTIONS = {
        :server           => :auto,
        :server_env       => 'development',
        :port             => 8888,
        :jasmine_url      => 'http://localhost:8888/jasmine',
        :timeout          => 10000,
        :notification     => true,
        :hide_success     => false,
        :all_on_start     => true,
        :keep_failed      => true,
        :all_after_pass   => true,
        :max_error_notify => 3,
        :specdoc          => :failure,
        :console          => :failure,
        :focus            => true
    }

    # Initialize Guard::Jasmine.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    # @option options [String] :server the server to use, either :auto, :none, :webrick, :mongrel, :thin, :jasmine_gem
    # @option options [String] :server_env the server environment to use, for example :development, :test
    # @option options [String] :port the port for the Jasmine test server
    # @option options [String] :jasmine_url the url of the Jasmine test runner
    # @option options [String] :phantomjs_bin the location of the PhantomJS binary
    # @option options [Integer] :timeout the maximum time in milliseconds to wait for the spec runner to finish
    # @option options [Boolean] :notification show notifications
    # @option options [Boolean] :hide_success hide success message notification
    # @option options [Integer] :max_error_notify maximum error notifications to show
    # @option options [Boolean] :all_on_start run all suites on start
    # @option options [Boolean] :keep_failed keep failed suites and add them to the next run again
    # @option options [Boolean] :all_after_pass run all suites after a suite has passed again after failing
    # @option options [Symbol] :specdoc options for the specdoc output, either :always, :never or :failure
    # @option options [Symbol] :console options for the console.log output, either :always, :never or :failure
    # @option options [Symbol] :focus options for focus on failures in the specdoc
    #
    def initialize(watchers = [], options = { })
      options[:jasmine_url] = "http://localhost:#{ options[:port] }/jasmine" if options[:port] && !options[:jasmine_url]
      options = DEFAULT_OPTIONS.merge(options)
      options[:specdoc] = :failure if ![:always, :never, :failure].include? options[:specdoc]
      options[:server] = :auto if ![:none, :webrick, :mongrel, :thin, :jasmine_gem].include? options[:server]
      options[:phantomjs_bin] = Jasmine.which('phantomjs') unless options[:phantomjs_bin]

      super(watchers, options)

      self.last_run_failed   = false
      self.last_failed_paths = []
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def start
      if phantomjs_bin_valid?(options[:phantomjs_bin])

        Server.start(options[:server], options[:port], options[:server_env]) unless options[:server] == :none

        if jasmine_runner_available?(options[:jasmine_url])
          run_all if options[:all_on_start]
        end
      else
        throw :task_has_failed
      end
    end

    # Gets called once when Guard stops.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def stop
      Server.stop unless options[:server] == :none
    end

    # Gets called when the Guard should reload itself.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def reload
      self.last_run_failed   = false
      self.last_failed_paths = []
    end

    # Gets called when all specs should be run.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_all
      passed, failed_specs = Runner.run(['spec/javascripts'], options)

      self.last_failed_paths = failed_specs
      self.last_run_failed   = !passed

      throw :task_has_failed unless passed
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_on_change(paths)
      specs = Inspector.clean(paths)
      return false if specs.empty?

      specs += self.last_failed_paths if options[:keep_failed]

      passed, failed_specs = Runner.run(specs, options)

      if passed
        self.last_failed_paths = self.last_failed_paths - paths
        run_all if self.last_run_failed && options[:all_after_pass]
      else
        self.last_failed_paths = self.last_failed_paths + failed_specs
      end

      self.last_run_failed = !passed

      throw :task_has_failed unless passed
    end

    private

    # Verifies if the Jasmine test runner is available.
    #
    # @param [String] url the location of the test runner
    # @return [Boolean] when the runner is available
    #
    def jasmine_runner_available?(url)
      url = URI.parse(url)

      begin
        Net::HTTP.start(url.host, url.port) do |http|
          response = http.request(Net::HTTP::Head.new(url.path))

          if response.code.to_i == 200
            Formatter.info("Jasmine test runner is available at #{ url }")
          else
            notify_failure("Jasmine test runner isn't available", "Jasmine test runner isn't available at #{ url }")
          end

          response.code.to_i == 200
        end

      rescue
        notify_failure("Jasmine test runner isn't available", "Jasmine test runner isn't available at #{ url }")

        false
      end
    end

    # Verifies that the phantomjs bin is available and the
    # right version is installed.
    #
    # @param [String] bin the location of the phantomjs bin
    # @return [Boolean] when the runner is available
    #
    def phantomjs_bin_valid?(bin)
      if bin && !bin.empty?
        version = `#{ bin } --version`

        if version
          # Remove all but version, e.g. from '1.5 (development)'
          version = version.match(/(\d\.)*(\d)/)[0]

          if Gem::Version.new(version) < Gem::Version.new('1.3.0')
            notify_failure('Wrong PhantomJS version', "PhantomJS executable at #{ bin } must be at least version 1.3.0")
          else
            true
          end
        else
          notify_failure('PhantomJS executable missing', "PhantomJS executable doesn't exist at #{ bin }")
        end
      else
        notify_failure('PhantomJS executable missing', "PhantomJS executable couldn't be auto detected.")
      end
    end

    # Notify a failure.
    #
    # @param title [String] the failure title
    # @param message [String] the failure message
    #
    def notify_failure(title, message)
      Formatter.error(message)
      Formatter.notify(message,
                       :title    => title,
                       :image    => :failed,
                       :priority => 2) if options[:notification]
      false
    end

    # Cross-platform way of finding an executable in the $PATH.
    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    #
    # @example
    #   which('ruby') #=> /usr/bin/ruby
    #
    # @param cmd [String] the executable to find
    # @return [String, nil] the path to the executable
    #
    def self.which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = "#{ path }/#{ cmd }#{ ext }"
          return exe if File.executable?(exe)
        end
      end

      nil
    end

  end
end
