module Guard
  class Jasmine
    module Runner
      class << self

        DESCRIBE_SUITE = /\s*describe\(?('|")(.*)('|")\s*/

        def run(files, options = { })
          return false if files.empty?

          message = options[:message] || (paths == ['spec/javascripts'] ? 'Run all specs' : "Run specs #{ files.join(' ') }")
          UI.info message, :reset => true

          files.inject([]) do |errors, file|
            output = system(phantomjs_command(file, options))
            errors << analyze_result(output)

            errors
          end.flatten.compact
        end

        private

        def phantomjs_command(file, options)
          "#{ options[:phantomjs_bin] } #{ phantomjs_script } #{ options[:jasmine_url] }?#{ suite_name_for(file) }"
        end

        def phantomjs_script
          File.expand_path(File.join('.', 'phantomjs', 'run-jasmine.coffee'))
        end

        def suite_name_for(file)
          return if file == 'spec/javascripts'

          File.open(file) do |io|
            io.each do |line|
              return Regexp.last_match(0) if line =~ DESCRIBE_SUITE
            end
          end
        end

        def analyze_result(output)
          if output =~ /(\d+) specs, (\d+) failure in (\d+.\d+)s/
            specs = Regexp.last_match(0)
            failures = Regexp.last_match(1)
            spec_time = Regexp.last_match(2)

            trip_time = output =~ /'waitFor\(\)' finished in (\d+)ms\./[0]
            message = "Jasmine ran #{ specs } specs, #{ failures } failure#{ failures == 1 ? '' : 's' } in #{ spec_time }s (#{ trip_time }ms)."

            if failures
              Formatter.error(message)
              Formatter.notify(message, :title => 'Jasmine results', :image => :failed, :priority => 2) if options[:notification]
            elsif
              Formatter.success(message)
              Formatter.notify(message, :title => 'Jasmine results') if options[:notification] && !options[:hide_success]
            end
          end
        end

      end
    end
  end
end
