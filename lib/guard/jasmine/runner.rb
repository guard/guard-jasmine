# coding: utf-8

require 'multi_json'

module Guard
  class Jasmine

    # The Jasmine runner handles the execution of the spec through the PhantomJS binary,
    # evaluates the JSON response from the PhantomJS Script `run_jasmine.coffee`,
    # writes the result to the console and triggers optional system notifications.
    #
    module Runner
      class << self

        # Run the supplied specs.
        #
        # @param [Array<String>] paths the spec files or directories
        # @param [Hash] options the options for the execution
        # @option options [String] :jasmine_url the url of the Jasmine test runner
        # @option options [String] :phantomjs_bin the location of the PhantomJS binary
        # @option options [Integer] :timeout the maximum time in milliseconds to wait for the spec runner to finish
        # @option options [Boolean] :notification show notifications
        # @option options [Boolean] :hide_success hide success message notification
        # @option options [Integer] :max_error_notify maximum error notifications to show
        # @option options [Symbol] :specdoc options for the specdoc output, either :always, :never
        # @option options [Symbol] :console options for the console.log output, either :always, :never or :failure
        # @return [Boolean, Array<String>] the status of the run and the failed files
        #
        def run(paths, options = { })
          return [false, []] if paths.empty?

          notify_start_message(paths)

          results = paths.inject([]) do |results, file|
            results << evaluate_response(run_jasmine_spec(file, options), file, options)

            results
          end.compact

          [response_status_for(results), failed_paths_from(results)]
        end

        private

        # Shows a notification in the console that the runner starts.
        #
        # @param [Array<String>] paths the spec files or directories
        #
        def notify_start_message(paths)
          message = if paths == ['spec/javascripts']
                      'Run all Jasmine suites'
                    else
                      "Run Jasmine suite#{ paths.size == 1 ? '' : 's' } #{ paths.join(' ') }"
                    end

          Formatter.info(message, :reset => true)
        end

        # Returns the failed spec file names.
        #
        # @param [Array<Object>] results the spec runner results
        # @return [Array<String>] the list of failed spec files
        #
        def failed_paths_from(results)
          results.map { |r| !r['passed'] ? r['file'] : nil }.compact
        end

        # Returns the response status for the given result set.
        #
        # @param [Array<Object>] results the spec runner results
        # @return [Boolean] whether it has passed or not
        #
        def response_status_for(results)
          results.none? { |r| r.has_key?('error') || !r['passed'] }
        end

        # Run the Jasmine spec by executing the PhantomJS script.
        #
        # @param [String] path the path of the spec
        # @param [Hash] options the options for the execution
        # @option options [Integer] :timeout the maximum time in milliseconds to wait for the spec runner to finish
        #
        def run_jasmine_spec(file, options)
          suite = jasmine_suite(file, options)
          Formatter.info("Run Jasmine suite at #{ suite }")
          IO.popen("#{ phantomjs_command(options) } \"#{ suite }\" #{ options[:timeout] }")
        end

        # Get the PhantomJS binary and script to execute.
        #
        # @param [Hash] options the options for the execution
        # @option options [String] :phantomjs_bin the location of the PhantomJS binary
        # @return [String] the command
        #
        def phantomjs_command(options)
          options[:phantomjs_bin] + ' ' + phantomjs_script
        end

        # Get the Jasmine test runner URL with the appended suite name
        # that acts as the spec filter.
        #
        # @param [Hash] options the options for the execution
        # @option options [String] :jasmine_url the url of the Jasmine test runner
        # @return [String] the Jasmine url
        #
        def jasmine_suite(file, options)
          options[:jasmine_url] + query_string_for_suite(file)
        end

        # Get the PhantomJS script that executes the spec and extracts
        # the result from the headless DOM.
        #
        # @return [String] the path to the PhantomJS script
        #
        def phantomjs_script
          File.expand_path(File.join(File.dirname(__FILE__), 'phantomjs', 'run-jasmine.coffee'))
        end

        # The suite name must be extracted from the spec that
        # will be run. This is done by parsing from the head of
        # the spec file until the first `describe` function is
        # found.
        #
        # @param [String] file the spec file
        # @return [String] the suite name
        #
        def query_string_for_suite(file)
          return '' if file == 'spec/javascripts'

          query_string = ''

          File.foreach(file) do |line|
            if line =~ /describe\s*[("']+(.*?)["')]+/
              query_string = "?spec=#{ $1 }"
              break
            end
          end

          URI.encode(query_string)
        end

        # Evaluates the JSON response that the PhantomJS script
        # writes to stdout. The results triggers further notification
        # actions.
        #
        # @param [String] output the JSON output the spec run
        # @param [String] file the file name of the spec
        # @param [Hash] options the options for the execution
        # @return [Hash] the suite result
        #
        def evaluate_response(output, file, options)
          json = output.read

          begin
            result = MultiJson.decode(json)

            if result['error']
              notify_runtime_error(result, options)
            else
              result['file'] = file
              notify_spec_result(result, options)
            end

            result

          rescue Exception => e
            Formatter.error("Cannot decode JSON from PhantomJS runner: #{ e.message }")
            Formatter.error('Please report an issue at: https://github.com/netzpirat/guard-jasmine/issues')
            Formatter.error("JSON response: #{ json }")
          ensure
            output.close
          end
        end

        # Notification when a system error happens that
        # prohibits the execution of the Jasmine spec.
        #
        # @param [Hash] the suite result
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :notification show notifications
        #
        def notify_runtime_error(result, options)
          message = "An error occurred: #{ result['error'] }"
          Formatter.error(message)
          Formatter.notify(message, :title => 'Jasmine error', :image => :failed, :priority => 2) if options[:notification]
        end

        # Notification about a spec run, success or failure,
        # and some stats.
        #
        # @param [Hash] result the suite result
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :notification show notifications
        # @option options [Boolean] :hide_success hide success message notification
        #
        def notify_spec_result(result, options)
          specs    = result['stats']['specs']
          failures = result['stats']['failures']
          time     = result['stats']['time']
          plural   = failures == 1 ? '' : 's'

          message = "#{ specs } specs, #{ failures } failure#{ plural }\nin #{ time } seconds"
          passed  = failures == 0

          if passed
            report_specdoc(result, passed, options) if options[:specdoc] == :always
            Formatter.success(message)
            Formatter.notify(message, :title => 'Jasmine suite passed') if options[:notification] && !options[:hide_success]
          else
            report_specdoc(result, passed, options) if options[:specdoc] != :never
            Formatter.error(message)
            notify_errors(result, options)
            Formatter.notify(message, :title => 'Jasmine suite failed', :image => :failed, :priority => 2) if options[:notification]
          end
        end

        # Specdoc like formatting of the result.
        #
        # @param [Hash] result the suite result
        # @param [Boolean] passed status
        # @param [Hash] options the options
        # @option options [Symbol] :console options for the console.log output, either :always, :never or :failure
        #
        def report_specdoc(result, passed, options)
          result['suites'].each do |suite|
            report_specdoc_suite(suite, passed, options)
          end
        end

        # Show the suite result.
        #
        # @param [Hash] suite the suite
        # @param [Boolean] passed status
        # @param [Hash] options the options
        # @option options [Symbol] :console options for the console.log output, either :always, :never or :failure
        # @option options [Symbol] :focus options for focus on failures in the specdoc
        # @param [Number] level the indention level
        #
        def report_specdoc_suite(suite, passed, options, level = 0)
          Formatter.suite_name((' ' * level) + suite['description']) if passed || options[:focus] && contains_failed_spec?(suite)

          suite['specs'].each do |spec|
            if spec['passed']
              if passed || !options[:focus]
                Formatter.success(indent("  ✔ #{ spec['description'] }", level))
                report_specdoc_logs(spec, options, level)
              end
            else
              Formatter.spec_failed(indent("  ✘ #{ spec['description'] }", level))
              spec['messages'].each do |message|
                Formatter.spec_failed(indent("    ➤ #{ format_message(message, false) }", level))
              end
              report_specdoc_logs(spec, options, level)
            end
          end

          suite['suites'].each { |suite| report_specdoc_suite(suite, passed, options, level + 2) } if suite['suites']
        end

        # Shows the logs for a given spec.
        #
        # @param [Hash] spec the spec result
        # @param [Hash] options the options
        # @option options [Symbol] :console options for the console.log output, either :always, :never or :failure
        # @param [Number] level the indention level
        #
        def report_specdoc_logs(spec, options, level)
          if spec['logs'] && (options[:console] == :always || (options[:console] == :failure && !spec['passed']))
            spec['logs'].each do |log|
              Formatter.info(indent("    • #{ format_message(log, true) }", level))
            end
          end
        end

        # Indent a message.
        #
        # @param [String] message the message
        # @param [Number] level the indention level
        #
        def indent(message, level)
          (' ' * level) + message
        end

        # Show system notifications about the occurred errors.
        #
        # @param [Hash] result the suite result
        # @param [Hash] options the options
        # @option options [Integer] :max_error_notify maximum error notifications to show
        # @option options [Boolean] :notification show notifications
        #
        def notify_errors(result, options)
          collect_specs(result['suites']).each_with_index do |spec, index|
            if !spec['passed'] && options[:max_error_notify] > index
              msg = spec['messages'].map { |message| format_message(message, true) }.join(', ')
              Formatter.notify("#{ spec['description'] }: #{ msg }",
                               :title    => 'Jasmine spec failed',
                               :image    => :failed,
                               :priority => 2) if options[:notification]
            end
          end
        end

        # Tests if the given suite has a failing spec underneath.
        #
        # @param [Hash] suite the suite result
        # @return [Boolean] the search result
        #
        def contains_failed_spec?(suite)
          collect_specs([suite]).any? { |spec| !spec['passed'] }
        end

        # Get all specs from the suites and its nested suites.
        #
        # @param suites [Array<Hash>] the suites results
        # @param [Array<Hash>] all specs
        #
        def collect_specs(suites)
          suites.inject([]) do |specs, suite|
            specs = (specs | suite['specs']) if suite['specs']
            specs = (specs | collect_specs(suite['suites'])) if suite['suites']
            specs
          end
        end

        # Formats a message.
        #
        # @param [String] message the error message
        # @param [Boolean] short show a short version of the message
        # @return [String] the cleaned error message
        #
        def format_message(message, short)
          if message =~ /(.*?) in http.+?assets\/(.*)\?body=\d+\s\((line\s\d+)/
            short ? $1 : "#{ $1 } in #{ $2 } on #{ $3 }"
          else
            message
          end
        end

      end
    end
  end
end
