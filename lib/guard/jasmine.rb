require 'net/http'

require 'guard'
require 'guard/guard'
require 'guard/watcher'

module Guard

  # The Jasmine guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class Jasmine < Guard

    require 'guard/jasmine/coverage'
    require 'guard/jasmine/inspector'
    require 'guard/jasmine/runner'
    require 'guard/jasmine/server'
    require 'guard/jasmine/util'

    extend ::Guard::Jasmine::Util

    attr_accessor :last_run_failed, :last_failed_paths, :run_all_options

    DEFAULT_OPTIONS = {
      :server               => :auto,
      :server_env           => ENV['RAILS_ENV'] || 'development',
      :server_timeout       => 60,
      :port                 => nil,
      :rackup_config        => nil,
      :jasmine_url          => nil,
      :timeout              => 60,
      :spec_dir             => 'spec/javascripts',
      :notification         => true,
      :hide_success         => false,
      :all_on_start         => true,
      :keep_failed          => true,
      :clean                => true,
      :all_after_pass       => true,
      :max_error_notify     => 3,
      :specdoc              => :failure,
      :console              => :failure,
      :errors               => :failure,
      :focus                => true,
      :coverage             => false,
      :coverage_html        => false,
      :coverage_summary     => false,
      :statements_threshold => 0,
      :functions_threshold  => 0,
      :branches_threshold   => 0,
      :lines_threshold      => 0
    }

    # Initialize Guard::Jasmine.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    # @option options [String] :server the server to use, either :auto, :none, :webrick, :mongrel, :thin, :jasmine_gem, or a custom rake task
    # @option options [String] :server_env the server environment to use, for example :development, :test
    # @option options [Integer] :server_timeout the number of seconds to wait for the Jasmine spec server
    # @option options [String] :port the port for the Jasmine test server
    # @option options [String] :rackup_config custom rackup config to use
    # @option options [String] :jasmine_url the url of the Jasmine test runner
    # @option options [String] :phantomjs_bin the location of the PhantomJS binary
    # @option options [Integer] :timeout the maximum time in seconds to wait for the spec runner to finish
    # @option options [String] :spec_dir the directory with the Jasmine specs
    # @option options [Boolean] :notification show notifications
    # @option options [Boolean] :hide_success hide success message notification
    # @option options [Integer] :max_error_notify maximum error notifications to show
    # @option options [Boolean] :all_on_start run all suites on start
    # @option options [Boolean] :keep_failed keep failed suites and add them to the next run again
    # @option options [Boolean] :clean clean the specs according to rails naming conventions
    # @option options [Boolean] :all_after_pass run all suites after a suite has passed again after failing
    # @option options [Symbol] :specdoc options for the specdoc output, either :always, :never or :failure
    # @option options [Symbol] :console options for the console.log output, either :always, :never or :failure
    # @option options [Symbol] :errors options for the errors output, either :always, :never or :failure
    # @option options [Symbol] :focus options for focus on failures in the specdoc
    # @option options [Symbol] :coverage options for enable coverage support
    # @option options [Symbol] :coverage_html options for enable coverage html support
    # @option options [Symbol] :coverage_summary options for enable coverage summary support
    # @option options [Symbol] :statements_threshold options for the statement coverage threshold
    # @option options [Symbol] :functions_threshold options for the statement function threshold
    # @option options [Symbol] :branches_threshold options for the statement branch threshold
    # @option options [Symbol] :lines_threshold options for the statement lines threshold
    # @option options [Hash] :run_all options overwrite options when run all specs
    #
    def initialize(watchers = [], options = { })
      options = DEFAULT_OPTIONS.merge(options)

      options[:port]        ||= Jasmine.find_free_server_port
      options[:server]      ||= :auto
      options[:server]        = ::Guard::Jasmine::Server.detect_server(options[:spec_dir]) if options[:server] == :auto
      options[:jasmine_url]   = "http://localhost:#{ options[:port] }#{ options[:server] == :jasmine_gem ? '/' : '/jasmine' }" unless options[:jasmine_url]
      options[:specdoc]       = :failure if ![:always, :never, :failure].include? options[:specdoc]
      options[:phantomjs_bin] = Jasmine.which('phantomjs') unless options[:phantomjs_bin]

      self.run_all_options = options.delete(:run_all) || { }

      super(watchers, options)

      self.last_run_failed   = false
      self.last_failed_paths = []
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def start
      if Jasmine.phantomjs_bin_valid?(options[:phantomjs_bin])

        Server.start(options) unless options[:server] == :none

        if Jasmine.runner_available?(options)
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
      passed, failed_specs = Runner.run([options[:spec_dir]], options.merge(self.run_all_options))

      self.last_failed_paths = failed_specs
      self.last_run_failed   = !passed

      throw :task_has_failed unless passed
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_on_changes(paths)
      specs = options[:keep_failed] ? paths + self.last_failed_paths : paths
      specs = Inspector.clean(specs, options) if options[:clean]
      return false if specs.empty?

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

  end
end

