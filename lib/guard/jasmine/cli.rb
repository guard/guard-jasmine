require 'thor'
require 'guard'
require 'guard/jasmine/version'
require 'guard/jasmine/runner'
require 'guard/jasmine/formatter'
require 'guard/jasmine/server'
require 'guard/jasmine/util'
require 'guard/jasmine/server'

module Guard
  class Jasmine < Plugin
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
                    type:    :string,
                    aliases: '-s',
                    default: 'auto',
                    desc:    'Server to start, either `auto`, `webrick`, `mongrel`, `thin`, `unicorn`, `jasmine_gem` or `none`'

      method_option :port,
                    type:    :numeric,
                    aliases: '-p',
                    desc:    'Server port to use'

      method_option :server_env,
                    type:    :string,
                    aliases: '-e',
                    default: ENV['RAILS_ENV'] || 'test',
                    desc:    'The server environment to use, for example `development`, `test` etc.'

      method_option :server_timeout,
                    type:    :numeric,
                    default: 60,
                    desc:    'The number of seconds to wait for the Jasmine spec server'

      method_option :verbose,
                    type:    :boolean,
                    default: false,
                    desc:    'Show the server output in the console'

      method_option :rackup_config,
                    type:    :string,
                    aliases: '-c',
                    desc:    'The rackup config to use (jasminerice only)'

      method_option :bin,
                    type:    :string,
                    aliases: '-b',
                    desc:    'The location of the PhantomJS binary'

      method_option :spec_dir,
                    type:    :string,
                    aliases: '-d',
                    desc:    'The directory with the Jasmine specs'

      method_option :line_number,
                    type:    :numeric,
                    aliases: '-l',
                    desc:    'The line which identifies the spec to be run'

      method_option :url,
                    type:    :string,
                    aliases: '-u',
                    desc:    'The url of the Jasmine test runner'

      method_option :mount,
                    type:    :string,
                    aliases: '-m',
                    desc:    'The mount point of the Jasmine test runner'

      method_option :timeout,
                    type:    :numeric,
                    aliases: '-t',
                    default: 60,
                    desc:    'The maximum time in seconds to wait for the spec runner to finish'

      method_option :console,
                    type:    :string,
                    default: 'failure',
                    desc:    'Whether to show console.log statements in the spec runner, either `always`, `never` or `failure`'

      method_option :errors,
                    type:    :string,
                    default: 'failure',
                    desc:    'Whether to show errors in the spec runner, either `always`, `never` or `failure`'

      method_option :focus,
                    type:    :boolean,
                    aliases: '-f',
                    default: true,
                    desc:    'Specdoc focus to hide successful tests when at least one test fails'

      method_option :specdoc,
                    type:    :string,
                    default: :always,
                    desc:    'Whether to show successes in the spec runner, either `always`, `never` or `failure`'

      method_option :coverage,
                    type:    :boolean,
                    default: false,
                    desc:    'Whether to enable the coverage support or not'

      method_option :coverage_html,
                    type:    :boolean,
                    default: false,
                    desc:    'Whether to generate html coverage report. Implies --coverage'

      method_option :coverage_html_dir,
                    type:    :string,
                    default: './coverage',
                    desc:    'Where to save html coverage reports. Defaults to ./coverage. Implies --coverage-html'

      method_option :coverage_summary,
                    type:    :boolean,
                    default: false,
                    desc:    'Whether to generate html coverage summary. Implies --coverage'

      method_option :ignore_instrumentation,
                    type:    :string,
                    default: '',
                    desc:    'Files matching this regex will not be instrumented (e.g. vendor)'

      method_option :statements_threshold,
                    type:    :numeric,
                    default: 0,
                    desc:    'Statements coverage threshold'

      method_option :functions_threshold,
                    type:    :numeric,
                    default: 0,
                    desc:    'Functions coverage threshold'

      method_option :branches_threshold,
                    type:    :numeric,
                    default: 0,
                    desc:    'Branches coverage threshold'

      method_option :lines_threshold,
                    type:    :numeric,
                    default: 0,
                    desc:    'Lines coverage threshold'

      method_option :reporters,
                    type:    :string,
                    default: nil,
                    desc:    'Comma separated list of jasmine reporters to use'


      # Run the Guard::Jasmine::Runner with options from
      # the command line.
      #
      # @param [Array<String>] paths the name of the specs to run
      #
      def spec(*paths)
        options = runner_options
        paths = [options[:spec_dir]] if paths.empty?
        if CLI.phantomjs_bin_valid?(options[:phantomjs_bin])
          catch(:task_has_failed) do
            ::Guard::Jasmine::Server.start(options) unless options[:server] == :none
          end
          if CLI.runner_available?(options)
            result = ::Guard::Jasmine::Runner.new(options).run(paths)
            ::Guard::Jasmine::Server.stop
            Process.exit result.empty? ? 0 : 1
          else
            Process.exit 2
          end

        else
          Process.exit 2
        end

      rescue => e
        Compat::UI.error "Something went wrong: #{e.message}"
        Process.exit 2
      ensure
        ::Guard::Jasmine::Server.stop
      end

      desc 'version', 'Show the Guard::Jasmine version'
      map %w(-v --version) => :version

      # Shows the current version of Guard::Jasmine.
      #
      # @see Guard::Jasmine::VERSION
      #
      def version
        Compat::UI.info "Guard::Jasmine version #{::Guard::JasmineVersion::VERSION}"
      end

      private

      def runner_options
        ro                            = {}
        ro[:port]                     = options.port || CLI.find_free_server_port
        ro[:spec_dir]                 = options.spec_dir || (File.exist?(File.join('spec', 'javascripts')) ? File.join('spec', 'javascripts') : 'spec')
        ro[:line_number]              = options.line_number
        ro[:server]                   = options.server.to_sym == :auto ? ::Guard::Jasmine::Server.detect_server(ro[:spec_dir]) : options.server.to_sym
        ro[:server_mount]             = options.mount || (defined?(JasmineRails) ? '/specs' : '/jasmine')
        ro[:jasmine_url]              = options.url || "http://localhost:#{ro[:port]}#{options.server.to_sym == :jasmine_gem ? '/' : ro[:server_mount]}"
        ro[:phantomjs_bin]            = options.bin || CLI.which('phantomjs')
        ro[:timeout]                  = options.timeout
        ro[:verbose]                  = options.verbose
        ro[:server_env]               = options.server_env
        ro[:server_timeout]           = options.server_timeout
        ro[:rackup_config]            = options.rackup_config
        ro[:console]                  = [:always, :never, :failure].include?(options.console.to_sym) ? options.console.to_sym : :failure
        ro[:errors]                   = [:always, :never, :failure].include?(options.errors.to_sym) ? options.errors.to_sym : :failure
        ro[:specdoc]                  = [:always, :never, :failure].include?(options.specdoc.to_sym) ? options.specdoc.to_sym : :always
        ro[:focus]                    = options.focus
        ro[:coverage]                 = options.coverage || options.coverage_html || options.coverage_summary || options.coverage_html_dir != './coverage'
        ro[:coverage_html]            = options.coverage_html || options.coverage_html_dir != './coverage'
        ro[:coverage_html_dir]        = options.coverage_html_dir
        ro[:coverage_summary]         = options.coverage_summary
        ro[:ignore_instrumentation]   = options.ignore_instrumentation
        ro[:statements_threshold]     = options.statements_threshold
        ro[:functions_threshold]      = options.functions_threshold
        ro[:branches_threshold]       = options.branches_threshold
        ro[:lines_threshold]          = options.lines_threshold
        ro[:notification]             = false
        ro[:hide_success]             = true
        ro[:max_error_notify]         = 0
        ro[:query_params]             = options.reporters ? { reporters: options.reporters } : nil
        ro[:is_cli]                   = true
        ro
      end

    end
  end
end
