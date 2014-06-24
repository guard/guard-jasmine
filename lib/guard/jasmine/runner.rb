# coding: utf-8

require 'multi_json'
require 'fileutils'
require 'guard/jasmine/util'

module Guard
  class Jasmine

    # The Jasmine runner handles the execution of the spec through the PhantomJS binary,
    # evaluates the JSON response from the PhantomJS Script `guard_jasmine.coffee`,
    # writes the result to the console and triggers optional system notifications.
    #
    class Runner
      include ::Guard::Jasmine::Util

      attr_reader :results, :options

      # Name of the coverage threshold options
      THRESHOLDS = [:statements_threshold, :functions_threshold, :branches_threshold, :lines_threshold]

      # Run the supplied specs.
      #
      # @param [Array<String>] paths the spec files or directories
      # @param [Hash] options the options for the execution
      # @option options [String] :jasmine_url the url of the Jasmine test runner
      # @option options [String] :phantomjs_bin the location of the PhantomJS binary
      # @option options [Integer] :timeout the maximum time in seconds to wait for the spec runner to finish
      # @option options [String] :rackup_config custom rackup config to use
      # @option options [Boolean] :notification show notifications
      # @option options [Boolean] :hide_success hide success message notification
      # @option options [Integer] :max_error_notify maximum error notifications to show
      # @option options [Symbol] :specdoc options for the specdoc output, either :always, :never
      # @option options [Symbol] :console options for the console.log output, either :always, :never or :failure
      # @option options [String] :spec_dir the directory with the Jasmine specs
      # @option options [Boolean] :debug display raw JSON output from the runner
      # @return [Boolean, Array<String>] the status of the run and the failed files
      #
      def initialize(options)
        @options = options
      end

      def run(paths, per_run_options = {})
        previous_options = @options
        @options.merge!( per_run_options )
        return [false, []] if paths.empty?

        notify_start_message(paths)

        @results = paths.inject([]) do |results, file|
          if File.exist?(file_and_line_number_parts(file)[0])
            results << evaluate_response(run_jasmine_spec(file), file) 
          end
          results
        end.compact
        [response_status, failed_paths]
      ensure
        @options=previous_options
      end

    private

      # Shows a notification in the console that the runner starts.
      #
        # @param [Array<String>] paths the spec files or directories
        #
        def notify_start_message(paths)
          message = if paths == [options[:spec_dir]]
                      'Run all Jasmine suites'
                    else
                      "Run Jasmine suite#{ paths.size == 1 ? '' : 's' } #{ paths.join(' ') }"
                    end

          Formatter.info(message, reset: true)
        end

        # Returns the failed spec file names.
        #
        # @param [Array<Object>] results the spec runner results
        # @return [Array<String>] the list of failed spec files
        #
        def failed_paths
          @results.map { |r| !r['passed'] ? r['file'] : nil }.compact
        end

        # Returns the response status for the given result set.
        #
        # @param [Array<Object>] results the spec runner results
        # @return [Boolean] whether it has passed or not
        #
        def response_status
          @results.none? { |r| r.has_key?('error') || !r['passed'] }
        end

        # Run the Jasmine spec by executing the PhantomJS script.
        #
        # @param [String] file the path of the spec
        #
        def run_jasmine_spec(file)
          suite = jasmine_suite(file)

          arguments = [
            options[:timeout] * 1000,
            options[:specdoc],
            options[:focus],
            options[:console],
            options[:errors],
            options[:junit],
            options[:junit_consolidate],
            "'#{ options[:junit_save_path] }'"
          ]

          IO.popen("#{ phantomjs_command } \"#{ suite }\" #{ arguments.collect { |i| i.to_s }.join(' ')}", 'r:UTF-8')
        end

        # Get the PhantomJS binary and script to execute.
        #
        # @return [String] the command
        #
        def phantomjs_command
          options[:phantomjs_bin] + ' ' + phantomjs_script
          #options[:phantomjs_bin] + ' --remote-debugger-port=9000 ' + phantomjs_script
        end

        # Get the Jasmine test runner URL with the appended suite name
        # that acts as the spec filter.
        #
        # @param [String] file the spec file
        # @return [String] the Jasmine url
        #
        def jasmine_suite(file)
          options[:jasmine_url] + query_string_for_suite(file)
        end

        # Get the PhantomJS script that executes the spec and extracts
        # the result from the headless DOM.
        #
        # @return [String] the path to the PhantomJS script
        #
        def phantomjs_script
          File.expand_path(File.join(File.dirname(__FILE__), 'phantomjs', 'guard-jasmine.js'))
        end

        # The suite name must be extracted from the spec that
        # will be run.
        #
        # @param [String] file the spec file
        # @return [String] the suite name
        #
        def query_string_for_suite(file)
          return '' if file == options[:spec_dir]

          query_string = query_string_for_suite_from_line_number(file)

          unless query_string
            query_string = query_string_for_suite_from_first_describe(file)
          end

          query_string = query_string ? "?spec=#{ query_string }" : ''

          URI.encode(query_string)
        end

        # When providing a line number by either the option or by
        # a number directly after the file name the suite is extracted
        # fromt the corresponding line number in the file.
        #
        # @param [String] file the spec file
        # @return [String] the suite name
        #
        def query_string_for_suite_from_line_number(file)
          file_name, line_number = file_and_line_number_parts(file)
          line_number ||= options[:line_number]

          if line_number
            lines = it_and_describe_lines(file_name, 0, line_number)
            last = lines.pop

            last_indentation = last[/^\s*/].length
            # keep only lines with lower indentation
            lines.delete_if { |x| x[/^\s*/].length >= last_indentation }
            # remove all 'it'
            lines.delete_if { |x| x =~ /^\s*it/ }

            lines << last
            lines.map { |x| spec_title(x) }.join(' ')
          end
        end

        # The suite name must be extracted from the spec that
        # will be run. This is done by parsing from the head of
        # the spec file until the first `describe` function is
        # found.
        #
        # @param [String] file the spec file
        # @return [String] the suite name
        #
        def query_string_for_suite_from_first_describe(file)
          File.foreach(file) do |line|
            if line =~ /describe\s*[("']+(.*?)["')]+/
              return $1
            end
          end
        end

        # Splits the file name into the physical file name
        # and the line number if present. E.g.:
        # 'some_spec.js.coffee:10' -> ['some_spec.js.coffee', 10].
        #
        # If the line number is missing the second part of the
        # returned array is `nil`.
        #
        # @param [String] file the spec file
        # @return [Array] `[file_name, line_number]`
        #
        def file_and_line_number_parts(file)
          match = file.match(/^(.+?)(?::(\d+))?$/)
          [match[1], match[2].nil? ? nil : match[2].to_i]
        end

        # Returns all lines of the file that are either a
        # 'describe' or a 'it' declaration.
        #
        # @param [String] file the spec file
        # @param [Numeric] from the first line in the range
        # @param [Numeric] to the last line in the range
        # @Return [Array] the line contents
        #
        def it_and_describe_lines(file, from, to)
          File.readlines(file)[from, to].
            select { |x| x =~ /^\s*(it|describe)/ }
        end

        # Extracts the title of a 'description' or a 'it' declaration.
        #
        # @param [String] the line content
        # @return [String] the extracted title
        #
        def spec_title(line)
          line[/['"](.+?)['"]/, 1]
        end

        # Evaluates the JSON response that the PhantomJS script
        # writes to stdout. The results triggers further notification
        # actions.
        #
        # @param [String] output the JSON output the spec run
        # @param [String] file the file name of the spec
        # @return [Hash] the suite result
        #
        def evaluate_response(output, file)
          json = output.read
          json = json.encode('UTF-8') if json.respond_to?(:encode)
          begin
            result = MultiJson.decode(json, { max_nesting: false })
            raise 'No response from Jasmine runner' if !result && options[:is_cli]
            pp result if options[:debug]
            if result['error']
              if options[:is_cli]
                raise 'An error occurred in the Jasmine runner'
              else
                notify_runtime_error(result)
              end
            elsif result
              result['file'] = file
              notify_spec_result(result)
            end

            if result && result['coverage'] && options[:coverage]
              notify_coverage_result(result['coverage'], file)
            end

            result

          rescue MultiJson::DecodeError => e
            if e.data == ''
              if options[:is_cli]
                raise 'No response from Jasmine runner'
              else
                Formatter.error('No response from the Jasmine runner!')
              end
            else
              if options[:is_cli]
                raise "Cannot decode JSON from PhantomJS runner, message received was:\n#{json}"
              else
                Formatter.error("Cannot decode JSON from PhantomJS runner: #{ e.message }")
                Formatter.error("JSON response: #{ e.data }")
                Formatter.error("message received was:\n#{json}")
              end
            end
          ensure
            output.close
          end
        end

        # Notification when a system error happens that
        # prohibits the execution of the Jasmine spec.
        #
        # @param [Hash] result the suite result
        #
        def notify_runtime_error(result)
          message = "An error occurred: #{ result['error'] }"
          Formatter.error(message )
          Formatter.error( result['trace'] ) if result['trace']
          Formatter.notify(message, title: 'Jasmine error', image: :failed, priority: 2) if options[:notification]
        end

        # Notification about a spec run, success or failure,
        # and some stats.
        #
        # @param [Hash] result the suite result
        #
        def notify_spec_result(result)
          specs           = result['stats']['specs']
          failures        = result['stats']['failures']
          time            = sprintf( '%0.2f', result['stats']['time'] )
          specs_plural    = specs == 1 ? '' : 's'
          failures_plural = failures == 1 ? '' : 's'
          Formatter.info("Finished in #{ time } seconds")

          message      = "#{ specs } spec#{ specs_plural }, #{ failures } failure#{ failures_plural }"
          full_message = "#{ message }\nin #{ time } seconds"
          passed       = failures == 0

          report_specdoc(result, passed) if specdoc_shown?(passed)

          if passed
            Formatter.success(message)
            Formatter.notify(full_message, title: 'Jasmine suite passed') if options[:notification] && !options[:hide_success]
          else
            errors = collect_specs(result['suites']||[]).map { |spec|
              (spec['errors']||[]).map { |error| format_error(error,false) }
            }.flatten

            error_message = errors[0..options[:max_error_notify]].join("\n")

            Formatter.error(message)
            if options[:notification]
              Formatter.notify( "#{error_message}\n#{full_message}",
                title: 'Jasmine suite failed', image: :failed, priority: 2)
            end
          end

        end

        # Notification about the coverage of a spec run, success or failure,
        # and some stats.
        #
        # @param [Hash] coverage the coverage hash from the JSON
        # @param [String] file the file name of the spec
        #
        def notify_coverage_result(coverage, file)
          if coverage_bin
            FileUtils.mkdir_p(coverage_root) unless File.exist?(coverage_root)

            update_coverage(coverage, file)

            if options[:coverage_summary]
              generate_summary_report
            else
              generate_text_report(file)
            end

            check_coverage

            if options[:coverage_html]
              generate_html_report
            end
          else
            Formatter.error('Skipping coverage report: unable to locate istanbul in your PATH')
          end
        end

        # Uses the Istanbul text reported to output the result of the
        # last coverage run.
        #
        # @param [String] file the file name of the spec
        #
        def generate_text_report(file)
          Formatter.info 'Spec coverage details:'

          if file == options[:spec_dir]
            matcher = /[|+]$/
          else
            impl    = file.sub('_spec', '').sub(options[:spec_dir], '')
            matcher = /(-+|All files|% Lines|#{ Regexp.escape(File.basename(impl)) }|#{ File.dirname(impl).sub(/^\//, '') }\/[^\/])/
          end

          puts ''

          `#{coverage_bin} report --root #{ coverage_root } text #{ coverage_file }`.each_line do |line|
            puts line.sub(/\n$/, '') if line =~ matcher
          end

          puts ''
        end

        # Uses the Istanbul text reported to output the result of the
        # last coverage run.
        #
        def check_coverage
          if any_coverage_threshold?
            coverage = `#{coverage_bin} check-coverage #{ istanbul_coverage_options } #{ coverage_file } 2>&1`
            coverage = coverage.split("\n").grep(/ERROR/).join.sub('ERROR:', '')
            failed   = $? && $?.exitstatus != 0

            if failed
              Formatter.error coverage
              Formatter.notify(coverage, title: 'Code coverage failed', image: :failed, priority: 2) if options[:notification]
            else
              Formatter.success 'Code coverage succeed'
              Formatter.notify('All code is adequately covered with specs', title: 'Code coverage succeed') if options[:notification] && !options[:hide_success]
            end
          end
        end

        # Uses the Istanbul text reported to output the result of the
        # last coverage run.
        #
        def generate_html_report
          report_directory = coverage_report_directory
          `#{coverage_bin} report --dir #{ report_directory } --root #{ coverage_root } html #{ coverage_file }`
          Formatter.info "Updated HTML report available at: #{ report_directory }/index.html"
        end

        # Uses the Istanbul text-summary reporter to output the
        # summary of all the coverage runs combined.
        #
        def generate_summary_report
          Formatter.info 'Spec coverage summary:'

          puts ''

          `#{coverage_bin} report --root #{ coverage_root } text-summary #{ coverage_file }`.each_line do |line|
            puts line.sub(/\n$/, '') if line =~ /\)$/
          end

          puts ''
        end

        # Specdoc like formatting of the result.
        #
        # @param [Hash] result the suite result
        # @param [Boolean] passed status
        #
        def report_specdoc(result, passed)
          result['suites'].each do |suite|
            report_specdoc_suite(suite, passed)
          end
        end

        # Show the suite result.
        #
        # @param [Hash] suite the suite
        # @param [Boolean] passed status
        # @param [Number] level the indention level
        #
        def report_specdoc_suite(suite, run_passed, level = 0)

         # Print the suite description when the specdoc is shown or there are logs to display
          Formatter.suite_name((' ' * level) + suite['description'])

          suite['specs'].each do |spec|
            # Specs are shown if they failed, or if they passed and the "focus" option is falsey
            # If the focus option is set, then only failing tests are shown
            next unless :always==options[:specdoc] || !spec['passed'] || ( !run_passed && !options[:focus] )
            if spec['passed']
              Formatter.success(indent("  ✔ #{ spec['description'] }", level))
            else
              Formatter.spec_failed(indent("  ✘ #{ spec['description'] }", level))
            end
            report_specdoc_errors(spec, level)
            report_specdoc_logs(spec, level)
          end

          suite['suites'].each { |s| report_specdoc_suite(s, run_passed, level + 2) } if suite['suites']
        end

        # Is the specdoc shown for this suite?
        #
        # @param [Boolean] passed the spec status
        #
        def specdoc_shown?(passed)
          options[:specdoc] == :always || (options[:specdoc] == :failure && !passed)
        end

        # Are console logs shown for this suite?
        #
        # @param [Hash] suite the suite
        # @param [Boolean] passed the spec status
        #
        def console_logs_shown?(suite, passed)
          # Are console messages displayed?
          console_enabled          = options[:console] == :always || (options[:console] == :failure && !passed)

          # Are there any logs to display at all for this suite?
          logs_for_current_options = suite['specs'].select do |spec|
            spec['logs'] && (options[:console] == :always || (options[:console] == :failure && !spec['passed']))
          end

          any_logs_present = !logs_for_current_options.empty?

          console_enabled && any_logs_present
        end

        # Are console logs shown for this spec?
        #
        # @param [Hash] spec the spec
        #
        def console_for_spec?(spec)
          spec['logs'] && ((spec['passed'] && options[:console] == :always) ||
            (!spec['passed'] && options[:console] != :never))
        end

        # Are error logs shown for this suite?
        #
        # @param [Hash] suite the suite
        # @param [Boolean] passed the spec status
        #
        def error_logs_shown?(suite, passed)
          # Are error messages displayed?
          errors_enabled             = options[:errors] == :always || (options[:errors] == :failure && !passed)

          # Are there any errors to display at all for this suite?
          errors_for_current_options = suite['specs'].select do |spec|
            spec['errors'] && (options[:errors] == :always || (options[:errors] == :failure && !spec['passed']))
          end

          any_errors_present= !errors_for_current_options.empty?

          errors_enabled && any_errors_present
        end

        # Are errors shown for this spec?
        #
        # @param [Hash] spec the spec
        def errors_for_spec?(spec)
          spec['errors'] && ((spec['passed'] && options[:errors] == :always) ||
            (!spec['passed'] && options[:errors] != :never))
        end

        # Is the description shown for this spec?
        #
        # @param [Boolean] passed the spec status
        # @param [Hash] spec the spec
        #
        def description_shown?(passed, spec)
          specdoc_shown?(passed) || console_for_spec?(spec) || errors_for_spec?(spec)
        end

        # Shows the logs for a given spec.
        #
        # @param [Hash] spec the spec result
        # @param [Number] level the indention level
        #
        def report_specdoc_logs(spec, level)
          if console_for_spec?(spec)
            spec['logs'].each do |log_level, message|
              log_level = log_level == 'log' ? '' : "#{log_level.upcase}: "
              Formatter.info(indent("    • #{log_level}#{ message }", level))
            end
          end
        end

        # Shows the errors for a given spec.
        #
        # @param [Hash] spec the spec result
        # @param [Number] level the indention level
        #
        def report_specdoc_errors(spec, level)
          if spec['errors'] && (options[:errors] == :always || (options[:errors] == :failure && !spec['passed']))
            spec['errors'].each do |error|
              Formatter.spec_failed(indent("    ➤ #{ format_error(error,true)  }", level))
              if error['trace']
                error['trace'].each do |trace|
                  Formatter.spec_failed(indent("    ➜ #{ trace['file'] } on line #{ trace['line'] }", level+2))
                end
              end
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
        # @return [Array<Hash>] all specs
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
        def format_error(error, short)
          message = error['message'].gsub(%r{ in http.*\(line \d+\)$},'')
          if !short && error['trace'] && error['trace'].length > 0
            location = error['trace'][0]
            "#{message} in #{location['file']}:#{location['line']}"
          else
            message
          end
        end

        # Updates the coverage data with new data for the implementation file.
        # It replaces the coverage data if the file is the spec dir.
        #
        # @param [Hash] coverage the last run coverage data
        # @param [String] file the file name of the spec
        #
        def update_coverage(coverage, file)
          if file == options[:spec_dir]
            File.write(coverage_file, MultiJson.encode(coverage, { max_nesting: false }))
          else
            if File.exist?(coverage_file)
              impl     = file.sub('_spec', '').sub(options[:spec_dir], '')
              coverage = MultiJson.decode(File.read(coverage_file), { max_nesting: false })

              coverage.each do |coverage_file, data|
                coverage[coverage_file] = data if coverage_file == impl
              end

              File.write(coverage_file, MultiJson.encode(coverage, { max_nesting: false }))
            else
              File.write(coverage_file, MultiJson.encode({ }))
            end
          end
        end

        # Do we should check the coverage?
        #
        # @return [Boolean] true if any coverage threshold is set
        #
        def any_coverage_threshold?
          THRESHOLDS.any? { |threshold| options[threshold] != 0 }
        end

        # Converts the options to Istanbul recognized options
        #
        # @return [String] the command line options
        #
        def istanbul_coverage_options
          THRESHOLDS.inject([]) do |coverage, name|
            threshold = options[name]
            coverage << (threshold != 0 ? "--#{ name.to_s.sub('_threshold', '') } #{ threshold }" : '')
          end.reject(&:empty?).join(' ')
        end

        # Returns the coverage executable path.
        #
        # @return [String] the path
        #
        def coverage_bin
          @coverage_bin ||= which 'istanbul'
        end

        # Get the coverage file to save all coverage data.
        # Creates `tmp/coverage` if not exists.
        #
        # @return [String] the filename to use
        #
        def coverage_file
          File.join(coverage_root, 'coverage.json')
        end

        # Create and returns the coverage root directory.
        #
        # @return [String] the coverage root
        #
        def coverage_root
          File.expand_path(File.join('tmp', 'coverage'))
        end

        # Creates and returns the coverage report directory.
        #
        # @return [String] the coverage report directory
        #
        def coverage_report_directory
          File.expand_path(options[:coverage_html_dir])
        end
    end
  end
end

