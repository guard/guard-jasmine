namespace :guard do
  namespace :jasmine do

    desc 'Wrap guard-jasmine for ci, options SERVER and PORT'
    task :ci => [:environment] do
      puts "Running Jasmine specs..."

      port = ENV['PORT'] || "5959"

      attempts = 0
      begin
        attempts += 1
        start_server port
        io = IO.popen("guard-jasmine spec http://0.0.0.0:#{port}/jasmine")
        output = io.readlines
        io.close
        stop_server port
        json = JSON::parse(output[1..output.length].join(''))
        process_json json
      rescue Exception => e
        puts "Error occurred. #{e.message}"
        if attempts < 2
          puts "Retrying..."
          retry
        else
          puts "Giving up"
        end
      end
    end
  end
end

def start_server port
  case ENV['SERVER']
  when "passenger"
    puts "Starting passenger on port #{port}"
    system "passenger start -p #{port} > /dev/null 2>&1 &"
  else
    system "rails server -p #{port} -d"
  end 
end

def stop_server port
  case ENV['SERVER']
  when "passenger"
    system "passenger stop --port #{port}"
  else
    system "kill -15 `cat tmp/pids/server.pid`"
  end
end

def process_json json
  if json["passed"] == true
    log_stats json
  else
    puts ""
    puts red("Failures:")
    puts ""
    fail_cnt = 1
    json["suites"].each {|suite|
      failing_specs = suite["specs"].select {|spec| spec["passed"] == false}
      failing_specs.each {|spec|
        puts "  #{fail_cnt}) #{spec['description']}"
        puts red("  Failure/Error: #{spec['error_message']}")
        puts ""
        fail_cnt += 1
      }
    }
    puts ""
    log_stats json, false 
    raise StandardError.new "Jasmine Specs Failed!"
  end
end


def log_stats json, passed = true
  puts "Finished in #{json['stats']['time']} seconds"
  counts = "#{json['stats']['specs']} examples, #{json['stats']['failures']} failures"
  puts passed == true ? green(counts) : red(counts)
end


def colorize(text, color_code)
  "#{color_code}#{text}\033[0m"
end

def red(text); colorize(text, "\033[0;31m"); end
def green(text); colorize(text, "\033[0;32m"); end


