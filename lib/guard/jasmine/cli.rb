require 'thor'
require 'guard/ui'
require 'guard/jasmine/version'
require 'guard/jasmine/runner'
require 'guard/jasmine/formatter'

module Guard
  class Jasmine

    # Small helper class to run the Jasmine runner once from the
    # command line. This can be useful to integrate guard-jasmine
    # into a continuous integration server.
    #
    # This outputs the specdoc and disables any notifications.
    #
    class CLI < Thor

      default_task :spec

      desc 'spec', 'Run the Jasmine spec runner'

      method_option :url,
                    :type => :string,
                    :aliases => '-u',
                    :default => 'http://127.0.0.1:3000/jasmine',
                    :desc => 'The url of the Jasmine test runner'

      method_option :bin,
                    :type => :string,
                    :aliases => '-b',
                    :default => '/usr/local/bin/phantomjs',
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

      # Run the Guard::Jasmine::Runner with options from
      # the command line.
      #
      # @param [Array<String>] paths the name of the specs to run
      #
      def spec(*paths)
        paths = ['spec/javascripts'] if paths.empty?

        runner = {}
        runner[:jasmine_url] = options.url
        runner[:phantomjs_bin] = options.bin
        runner[:timeout] = options.timeout
        runner[:console] = [:always, :never, :failure].include?(options.console.to_sym) ? options.console.to_sym : :failure

        runner[:notification] = false
        runner[:hide_success] = true
        runner[:max_error_notify] = 0
        runner[:specdoc] = :always

        result = ::Guard::Jasmine::Runner.run(paths, runner)
        result = result.first ? 0 : 1

        #::Guard::UI.error e.message

        Process.exit! result
      end

      desc 'version', 'Show the Guard::Jasmine version'
      map %w(-v --version) => :version

      # Shows the current version of Guard::Jasmine.
      #
      # @see Guard::Jasmine::VERSION
      #
      def version
        ::Guard::UI.info "Guard::Jasmine version #{ ::Guard::JasmineVersion }"
      end

    end
  end
end
