require 'thor'
require 'guard/ui'
require 'guard/jasmine/version'
require 'guard/jasmine/runner'
require 'guard/jasmine/formatter'
require 'guard/jasmine/server'
require 'guard/jasmine/util'

module Guard
  class Jasmine

    # Small helper class to run the Jasmine runner once from the
    # command line. This can be useful to integrate guard-jasmine
    # into a continuous integration server.
    #
    # This outputs the specdoc and disables any notifications.
    #
    class CLI < Thor
      extend Util

      default_task :spec

      desc 'spec', 'Run the Jasmine spec runner'

      method_option :focus,
                    :type => :boolean,
                    :aliases => '-f',
                    :default => true,
                    :desc    => 'Specdoc focus to hide successful tests when at least one test fails'

      method_option :server,
                    :type => :string,
                    :aliases => '-s',
                    :default => 'auto',
                    :desc => 'Server to start, either `auto`, `webrick`, `mongrel`, `thin`, `unicorn`, `jasmine_gem` or `none`'

      method_option :port,
                    :type => :numeric,
                    :aliases => '-p',
                    :default => 3001,
                    :desc => 'Server port to use'

      method_option :url,
                    :type => :string,
                    :aliases => '-u',
                    :default => 'http://localhost:3001/jasmine',
                    :desc => 'The url of the Jasmine test runner'

      method_option :bin,
                    :type => :string,
                    :aliases => '-b',
                    :desc => 'The location of the PhantomJS binary'

      method_option :timeout,
                    :type => :numeric,
                    :aliases => '-t',
                    :default => 10000,
                    :desc => 'The maximum time in milliseconds to wait for the spec runner to finish'

      method_option :console,
                    :type => :string,
                    :aliases => '-c',
                    :default => 'failure',
                    :desc => 'Whether to show console.log statements in the spec runner, either `always`, `never` or `failure`'

      method_option :errors,
                    :type => :string,
                    :aliases => '-x',
                    :default => 'failure',
                    :desc => 'Whether to show errors in the spec runner, either `always`, `never` or `failure`'

      method_option :server_env,
                    :type => :string,
                    :aliases => '-e',
                    :default => ENV['RAILS_ENV'] || 'test',
                    :desc => 'The server environment to use, for example `development`, `test` etc.'

      method_option :spec_dir,
                    :type => :string,
                    :aliases => '-d',
                    :default => 'spec/javascripts',
                    :desc => 'The directory with the Jasmine specs'

      # Run the Guard::Jasmine::Runner with options from
      # the command line.
      #
      # @param [Array<String>] paths the name of the specs to run
      #
      def spec(*paths)
        paths = [options.spec_dir] if paths.empty?

        runner = {}
        runner[:jasmine_url] = options.url
        runner[:phantomjs_bin] = options.bin || CLI.which('phantomjs')
        runner[:timeout] = options.timeout
        runner[:port] = options.port
        runner[:server_env] = options.server_env
        runner[:spec_dir] = options.spec_dir
        runner[:console] = [:always, :never, :failure].include?(options.console.to_sym) ? options.console.to_sym : :failure
        runner[:errors] = [:always, :never, :failure].include?(options.errors.to_sym) ? options.errors.to_sym : :failure
        runner[:server] = options.server.to_sym
        runner[:focus] = options.focus


        runner[:notification] = false
        runner[:hide_success] = true

        runner[:max_error_notify] = 0
        runner[:specdoc] = :always

        if CLI.phantomjs_bin_valid?(runner[:phantomjs_bin])
          ::Guard::Jasmine::Server.start(runner[:server], runner[:port], runner[:server_env], runner[:spec_dir]) unless runner[:server] == :none

          if CLI.runner_available?(runner[:jasmine_url])
            result = ::Guard::Jasmine::Runner.run(paths, runner)
            ::Guard::Jasmine::Server.stop

            Process.exit result.first ? 0 : 1
          else
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
