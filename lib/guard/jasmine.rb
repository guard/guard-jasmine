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

    # Initialize Guard::Jasmine.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    # @option options [String] :jasmine_url the url of the Jasmine test runner
    # @option options [String] :phantomjs_bin the location of the PhantomJS binary
    # @option options [Boolean] :notification show notifications
    # @option options [Boolean] :hide_success hide success message notification
    # @option options [Boolean] :all_on_start run all suites on start
    #
    def initialize(watchers = [], options = { })
      defaults = {
          :jasmine_url   => 'http://localhost:3000/jasmine',
          :phantomjs_bin => '/usr/local/bin/phantomjs',
          :notification  => true,
          :hide_success  => false,
          :all_on_start  => true
      }

      super(watchers, defaults.merge(options))
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

    # Gets called when all specs should be run.
    #
    # @return [Boolean] when running all specs was successful
    #
    def run_all
      Runner.run(['spec/javascripts'], options)
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @return [Boolean] when running the changed specs was successful
    #
    def run_on_change(paths)
      Runner.run(Inspector.clean(paths), options)

      #TODO: Evaluate result
    end

    private

    # Verifies if the Jasmine test runner is available.
    #
    # @param [String] url the location of the test runner
    # @return [Boolean] when the runner is available
    #
    def jasmine_runner_available?(url)
      url = URI.parse(url)

      Net::HTTP.start(url.host, url.port) do |http|
        if http.request(Net::HTTP::Head.new(url.path)).code != 200
          message = "Jasmine test runner not available at #{ url }"
          Formatter.error(message)

          if options[:notification]
            Formatter.notify(message, :title => 'Jasmine test runner', :image => :failed, :priority => 2)
          end

          false
        else
          Formatter.info("Jasmine test runner is available at #{ url }")

          true
        end
      end
    end

  end
end
