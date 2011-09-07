require 'multi_json'

module Guard
  class Jasmine
    module Runner
      class << self

        def run(files, options = { })
          return false if files.empty?

          message = options[:message] || (files == ['spec/javascripts'] ? 'Run all specs' : "Run specs #{ files.join(' ') }")
          UI.info message, :reset => true

          files.inject([]) do |results, file|
            results << notify_result(run_jasmine(file, options), options)

            results
          end.compact
        end

        private

        def run_jasmine(file, options)
            suite = jasmine_suite(file, options)
            Formatter.info("Run Jasmine tests: #{ suite }")
            IO.popen(phantomjs_command(options) + ' ' + suite)
        end

        def phantomjs_command(options)
           options[:phantomjs_bin] + ' ' + phantomjs_script
        end

        def jasmine_suite(file, options)
          options[:jasmine_url] + suite_query_for(file)
        end

        def phantomjs_script
          File.expand_path(File.join(File.dirname(__FILE__), 'phantomjs', 'run-jasmine.coffee'))
        end

        def suite_query_for(file)
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

        def notify_result(output, options)
          result = MultiJson.decode(output.read)
          output.close

          if result['error']
            notify_runtime_error(result, options)
          else
            notify_spec_result(result, options)
          end

          result
        end

        def notify_runtime_error(result, options)
          message = "An error occurred: #{ result['error'] }"
          Formatter.error(message)
          Formatter.notify(message, :title => 'Jasmine error', :image => :failed, :priority => 2) if options[:notification]
        end

        def notify_spec_result(result, options)
          specs    = result['stats']['specs']
          failures = result['stats']['failures']
          time     = result['stats']['time']
          plural   = failures == 1 ? '' : 's'

          message = "Jasmine ran #{ specs } specs, #{ failures } failure#{ plural } in #{ time }s."

          if failures != 0
            notify_spec_failures(result, message, options)
          else
            Formatter.success(message)
            Formatter.notify(message, :title => 'Jasmine results') if options[:notification] && !options[:hide_success]
          end
        end

        def notify_spec_failures(result, stats, options)
          messages = result['suites'].inject('') do |messages, suite|
            suite['specs'].each do |spec|
              messages << "Spec '#{ spec['description'] }' failed with '#{ spec['error_message'] }'!\n"
            end

            messages
          end

          messages << stats

          Formatter.error(messages)
          Formatter.notify(messages, :title => 'Jasmine results', :image => :failed, :priority => 2) if options[:notification]
        end

      end
    end
  end
end
