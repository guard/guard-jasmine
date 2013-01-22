require 'thor'
require 'guard/ui'
require 'guard/jasmine/version'
require 'guard/jasmine/runner'
require 'guard/jasmine/formatter'
require 'guard/jasmine/server'
require 'guard/jasmine/util'

module Guard
  class Jasmine

    # Small helper class to run the Jasmine runner_options once from the
    # command line. This can be useful to integrate guard-jasmine
    # into a continuous integration server.
    #
    # This outputs the specdoc and disables any notifications.
    #
    class CLI < Thor
      extend Util

      default_task :spec

      desc 'spec', 'Run the Jasmine spec runner_options'

      method_option :server,
                    :type    => :string,
                    :aliases => '-s',
                    :default => 'auto',
                    :desc    => 'Server to start, either `auto`, `webrick`, `mongrel`, `thin`, `unicorn`, `jasmine_gem` or `none`'

      method_option :port,
                    :type    => :numeric,
                    :aliases => '-p',
                    :desc    => 'Server port to use'

      method_option :server_env,
                    :type    => :string,
                    :aliases => '-e',
                    :default => ENV['RAILS_ENV'] || 'test',
                    :desc    => 'The server environment to use, for example `development`, `test` etc.'

      method_option :server_timeout,
                    :type    => :numeric,
                    :default => 15,
                    :desc    => 'The number of seconds to wait for the Jasmine spec server'

      method_option :rackup_config,
                    :type    => :string,
                    :aliases => '-c',
                    :desc    => 'The rackup config to use (jasminerice only)'

      method_option :bin,
                    :type    => :string,
                    :aliases => '-b',
                    :desc    => 'The location of the PhantomJS binary'

      method_option :spec_dir,
                    :type    => :string,
                    :aliases => '-d',
                    :default => 'spec/javascripts',
                    :desc    => 'The directory with the Jasmine specs'

      method_option :url,
                    :type    => :string,
                    :aliases => '-u',
                    :desc    => 'The url of the Jasmine test runner'

      method_option :timeout,
                    :type    => :numeric,
                    :aliases => '-t',
                    :default => 10,
                    :desc    => 'The maximum time in seconds to wait for the spec runner to finish'

      method_option :console,
                    :type    => :string,
                    :default => 'failure',
                    :desc    => 'Whether to show console.log statements in the spec runner, either `always`, `never` or `failure`'

      method_option :errors,
                    :type    => :string,
                    :default => 'failure',
                    :desc    => 'Whether to show errors in the spec runner, either `always`, `never` or `failure`'

      method_option :focus,
                    :type    => :boolean,
                    :aliases => '-f',
                    :default => true,
                    :desc    => 'Specdoc focus to hide successful tests when at least one test fails'

      method_option :specdoc,
                    :type    => :string,
                    :default => :always,
                    :desc    => 'Whether to show successes in the spec runner, either `always`, `never` or `failure`'

      method_option :coverage,
                    :type    => :boolean,
                    :default => false,
                    :desc    => 'Whether to enable the coverage support or not'

      method_option :statements_threshold,
                    :type    => :numeric,
                    :default => 0,
                    :desc    => 'Statements coverage threshold'

      method_option :functions_threshold,
                    :type    => :numeric,
                    :default => 0,
                    :desc    => 'Functions coverage threshold'

      method_option :branches_threshold,
                    :type    => :numeric,
                    :default => 0,
                    :desc    => 'Branches coverage threshold'

      method_option :lines_threshold,
                    :type    => :numeric,
                    :default => 0,
                    :desc    => 'Lines coverage threshold'

      # Run the Guard::Jasmine::Runner with options from
      # the command line.
      #
      # @param [Array<String>] paths the name of the specs to run
      #
      def spec(*paths)
        paths = [options.spec_dir] if paths.empty?

        runner_options                        = { }
        runner_options[:port]                 = options.port || CLI.find_free_server_port
        runner_options[:jasmine_url]          = options.url || "http://localhost:#{ runner_options[:port] }#{ options.server.to_sym == :jasmine_gem ? '/' : '/jasmine' }"
        runner_options[:phantomjs_bin]        = options.bin || CLI.which('phantomjs')
        runner_options[:timeout]              = options.timeout
        runner_options[:server]               = options.server.to_sym
        runner_options[:server_env]           = options.server_env
        runner_options[:server_timeout]       = options.server_timeout
        runner_options[:rackup_config]        = options.rackup_config
        runner_options[:spec_dir]             = options.spec_dir
        runner_options[:console]              = [:always, :never, :failure].include?(options.console.to_sym) ? options.console.to_sym : :failure
        runner_options[:errors]               = [:always, :never, :failure].include?(options.errors.to_sym) ? options.errors.to_sym : :failure
        runner_options[:specdoc]              = [:always, :never, :failure].include?(options.specdoc.to_sym) ? options.specdoc.to_sym : :always
        runner_options[:focus]                = options.focus
        runner_options[:coverage]             = options.coverage
        runner_options[:statements_threshold] = options.statements_threshold
        runner_options[:functions_threshold]  = options.functions_threshold
        runner_options[:branches_threshold]   = options.branches_threshold
        runner_options[:lines_threshold]      = options.lines_threshold
        runner_options[:notification]         = false
        runner_options[:hide_success]         = true
        runner_options[:max_error_notify]     = 0

        if CLI.phantomjs_bin_valid?(runner_options[:phantomjs_bin])
          catch(:task_has_failed) do
            ::Guard::Jasmine::Server.start(runner_options) unless runner_options[:server] == :none
          end

          if CLI.runner_available?(runner_options)
            result = ::Guard::Jasmine::Runner.run(paths, runner_options)
            ::Guard::Jasmine::Server.stop

            Process.exit result.first ? 0 : 1
          else
            ::Guard::Jasmine::Server.stop
            Process.exit 2
          end

        else
          Process.exit 2
        end

      rescue => e
        ::Guard::UI.error e.message
        Process.exit 2
      end

      desc 'version', 'Show the Guard::Jasmine version'
      map %w(-v --version) => :version

      # Shows the current version of Guard::Jasmine.
      #
      # @see Guard::Jasmine::VERSION
      #
      def version
        ::Guard::UI.info "Guard::Jasmine version #{ ::Guard::JasmineVersion::VERSION }"
      end

    end
  end
end
