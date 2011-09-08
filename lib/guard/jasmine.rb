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

    attr_accessor :last_run_failed, :last_failed_paths

    # Initialize Guard::Jasmine.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    # @option options [String] :jasmine_url the url of the Jasmine test runner
    # @option options [String] :phantomjs_bin the location of the PhantomJS binary
    # @option options [Boolean] :notification show notifications
    # @option options [Boolean] :hide_success hide success message notification
    # @option options [Boolean] :all_on_start run all suites on start
    # @option options [Boolean] :keep_failed keep failed specs and add them the next run again
    # @option options [Boolean] :all_after_pass run all specs after a single spec has passed
    #
    def initialize(watchers = [], options = { })
      defaults = {
          :jasmine_url    => 'http://localhost:3000/jasmine',
          :phantomjs_bin  => '/usr/local/bin/phantomjs',
          :notification   => true,
          :hide_success   => false,
          :all_on_start   => true,
          :keep_failed    => true,
          :all_after_pass => true
      }

      super(watchers, defaults.merge(options))

      self.last_run_failed   = false
      self.last_failed_paths = []
    end

    # Gets called once when Guard starts.
    #
    # @return [Boolean] when the start was successful
    #
    def start
      if jasmine_runner_available?(options[:jasmine_url])
        run_all if options[:all_on_start]
      end

      true
    end

    # Gets called when the Guard should reload itself.
    #
    # @return [Boolean] when the reload was successful
    #
    def reload
      self.last_run_failed   = false
      self.last_failed_paths = []

      true
    end

    # Gets called when all specs should be run.
    #
    # @return [Boolean] when running all specs was successful
    #
    def run_all
      passed, failed_specs = Runner.run(['spec/javascripts'], options)

      self.last_failed_paths = failed_specs
      self.last_run_failed   = !passed

      passed
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @return [Boolean] when running the changed specs was successful
    #
    def run_on_change(paths)
      paths += self.last_failed_paths if options[:keep_failed]

      passed, failed_specs = Runner.run(Inspector.clean(paths), options)

      if passed
        self.last_failed_paths = self.last_failed_paths - paths
        run_all if self.last_run_failed && options[:all_after_pass]
      else
        self.last_failed_paths = self.last_failed_paths + failed_specs
      end

      self.last_run_failed = !passed

      passed
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
            notify_jasmine_runner_failure(url) if options[:notification]
          end

          response.code.to_i == 200
        end

      rescue Errno::ECONNREFUSED => e
        notify_jasmine_runner_failure(url)

        false
      end
    end

    # Notify that the Jasmine runner is not available.
    #
    # @param [String] url the url of the Jasmine runner
    #
    def notify_jasmine_runner_failure(url)
      message = "Jasmine test runner not available at #{ url }"
      Formatter.error(message)
      Formatter.notify(message,
                       :title    => 'Jasmine test runner not available',
                       :image    => :failed,
                       :priority => 2)
    end

  end
end
