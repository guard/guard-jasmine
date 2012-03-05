# coding: utf-8

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
        # @param [String] strategy the server strategy to use
        # @param [Number] port the server port
        # @param [String] environment the Rails environment
        #
        def start(strategy, port, environment)
          strategy = detect_server if strategy == :auto

          case strategy
          when :webrick, :mongrel, :thin
            start_rack_server(port, environment, strategy)
          when :jasmine_gem
            start_jasmine_gem_server(port)
          end

          wait_for_server(port) unless strategy == :none
        end

        # Stop the server thread.
        #
        def stop
          ::Guard::UI.info "Guard::Jasmine stops server."
          self.process.stop(5)
        end

        private

        # Start the Rack server of the current project. This
        # will simply start a server that uses the `config.ru`
        # in the current directory.
        #
        # @param [Number] port the server port
        # @param [String] environment the Rails environment
        # @param [Symbol] server the rack server to use
        #
        def start_rack_server(port, environment, server)
          ::Guard::UI.info "Guard::Jasmine starts #{ server } test server on port #{ port } in #{ environment } environment."

          self.process = ChildProcess.build('rackup', '-E', environment.to_s, '-p', port.to_s, '-s', server.to_s)
          self.process.io.inherit! if ::Guard.respond_to?(:options) && ::Guard.options[:verbose]
          self.process.start

        rescue => e
          ::Guard::UI.error "Cannot start Rack server: #{ e.message }"
        end

        # Start the Jasmine gem server of the current project.
        #
        # @param [Number] port the server port
        #
        def start_jasmine_gem_server(port)
          ::Guard::UI.info "Guard::Jasmine starts Jasmine Gem test server on port #{ port }."

          self.process = ChildProcess.build('rake', 'jasmine', "JASMINE_PORT=#{ port }")
          self.process.io.inherit! if ::Guard.respond_to?(:options) && ::Guard.options[:verbose]
          self.process.start

        rescue => e
          ::Guard::UI.error "Cannot start Jasmine Gem server: #{ e.message }"
        end

        # Detect the server to use
        #
        # @return [Symbol] the server strategy
        #
        def detect_server
          if File.exists?('config.ru')
            :webrick
          elsif File.exists?(File.join('spec', 'javascripts', 'support', 'jasmine.yml'))
            :jasmine_gem
          else
            :none
          end
        end

        # Wait until the Jasmine test server is running.
        #
        # @param [Number] port the server port
        #
        def wait_for_server(port)
          require 'socket'

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

      end
    end

  end
end
