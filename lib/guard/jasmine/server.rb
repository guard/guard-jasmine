# coding: utf-8

require 'socket'
require 'timeout'
require 'childprocess'

module Guard
  class Jasmine

    # Start and stop a Jasmine test server for requesting the specs
    # from PhantomJS.
    #
    module Server
      class << self

        attr_accessor :process

        # Start the internal test server for getting the Jasmine runner.
        #
        # @param [Hash] options the server options
        # @option options [String] server the server to use
        # @option options [Number] port the server port
        # @option options [String] server_env the Rails environment
        # @option options [Number] server_timeout the server start timeout
        # @option options [String] spec_dir the spec directory
        # @option options [String] rackup_config custom rackup config to use (i.e. spec/dummy/config.ru for mountable engines)
        #
        def start(options)
          server  = options[:server]
          port    = options[:port]
          timeout = options[:server_timeout]

          case server
            when :webrick, :mongrel, :thin, :puma
              start_rack_server(server, port, options)
            when :unicorn
              start_unicorn_server(port, options)
            when :jasmine_gem
              start_rake_server(port, 'jasmine', options)
            else
              start_rake_server(port, server.to_s, options) unless server == :none
          end

          wait_for_server(port, timeout) unless server == :none
        end

        # Stop the server thread.
        #
        def stop
          if self.process
            ::Guard::UI.info 'Guard::Jasmine stops server.'
            self.process.stop(5)
          end
        end

        # Detect the server to use
        #
        # @param [String] spec_dir the spec directory
        # @return [Symbol] the server strategy
        #
        def detect_server(spec_dir)
          if File.exists?('config.ru')
            %w(unicorn thin mongrel puma).each do |server|
              begin
                require server
                return server.to_sym
              rescue LoadError
                # Ignore missing server and try next
              end
            end
            :webrick
          elsif spec_dir && File.exists?(File.join(spec_dir, 'support', 'jasmine.yml'))
            :jasmine_gem
          else
            :none
          end
        end

        private

        # Start the Rack server of the current project. This
        # will simply start a server that uses the `config.ru`
        # in the current directory.
        #
        # @param [Symbol] server the server name
        # @param [Integer] port the server port
        # @param [Hash] options the server options
        # @option options [Symbol] server the rack server to use
        # @option options [String] server_env the Rails environment
        # @option options [String] rackup_config custom rackup config to use (i.e. spec/dummy/config.ru for mountable engines)
        #
        def start_rack_server(server, port, options)
          environment   = options[:server_env]
          rackup_config = options[:rackup_config]
          coverage      = options[:coverage] ? 'on' : 'off'

          ::Guard::UI.info "Guard::Jasmine starts #{ server } spec server on port #{ port } in #{ environment } environment (coverage #{ coverage })."

          self.process = ChildProcess.build(*['rackup', '-E', environment.to_s, '-p', port.to_s, '-s', server.to_s, rackup_config].compact)
          self.process.environment['COVERAGE'] = options[:coverage].to_s
          self.process.io.inherit! if options[:verbose]
          self.process.start

        rescue => e
          ::Guard::UI.error "Cannot start Rack server: #{ e.message }"
        end

        # Start the Rack server of the current project. This
        # will simply start a server that uses the `config.ru`
        # in the current directory.
        #
        # @param [Hash] options the server options
        # @option options [String] server_env the Rails environment
        # @option options [Number] port the server port
        #
        def start_unicorn_server(port, options)
          environment = options[:server_env]
          coverage    = options[:coverage] ? 'on' : 'off'

          ::Guard::UI.info "Guard::Jasmine starts Unicorn spec server on port #{ port } in #{ environment } environment (coverage #{ coverage })."

          self.process = ChildProcess.build('unicorn_rails', '-E', environment.to_s, '-p', port.to_s)
          self.process.environment['COVERAGE'] = options[:coverage].to_s
          self.process.io.inherit! if options[:verbose]
          self.process.start

        rescue => e
          ::Guard::UI.error "Cannot start Unicorn server: #{ e.message }"
        end

        # Start the Jasmine gem server of the current project.
        #
        # @param [Number] port the server port
        # @param [String] task the rake task name
        # @option options [Symbol] server the rack server to use
        #
        def start_rake_server(port, task, options)
          ::Guard::UI.info "Guard::Jasmine starts Jasmine Gem test server on port #{ port }."

          self.process = ChildProcess.build('ruby', '-S', 'rake', task, "JASMINE_PORT=#{ port }")
          self.process.io.inherit! if options[:verbose]
          self.process.start

        rescue => e
          ::Guard::UI.error "Cannot start Rake task server: #{ e.message }"
        end

        # Wait until the Jasmine test server is running.
        #
        # @param [Number] port the server port
        # @param [Number] timeout the server wait timeout
        #
        def wait_for_server(port, timeout)
          Timeout::timeout(timeout) do
            while true
              begin
                ::TCPSocket.new('127.0.0.1', port).close
                break
              rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
                # Ignore, server still not available
              end
              sleep 0.1
            end
          end

        rescue Timeout::Error
          ::Guard::UI.warning 'Timeout while waiting for the server startup. You may need to increase the `:server_timeout` option.'
          throw :task_has_failed
        end

      end
    end

  end
end
