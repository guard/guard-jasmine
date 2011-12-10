# coding: utf-8

module Guard
  class Jasmine

    # Start and stop a Jasmine test server for requesting the specs
    # from PhantomJS.
    #
    module Server
      class << self

        attr_accessor :thread

        # Start the internal test server for getting the Jasmine runner.
        #
        # @param [String] strategy the server strategy to use
        # @param [Number] port the server port
        # @param [String] environment the Rails environment
        #
        def start(strategy, port, environment)
          strategy = detect_server if strategy == :auto

          case strategy
          when :rack
            start_rack_server(port, environment)
          when :jasmine_gem
            start_jasmine_gem_server(port)
          end

          wait_for_server(port) unless strategy == :none
        end

        # Stop the server thread.
        #
        def stop
          self.thread.kill if self.thread && self.thread.alive?
        end

        private

        # Start the Rack server of the current project. This
        # will simply start a server that uses the `config.ru`
        # in the current directory.
        #
        # @param [Number] port the server port
        # @param [String] environment the Rails environment
        #
        def start_rack_server(port, environment)
          require 'rack'

          ::Guard::UI.info "Guard::Jasmine starts Rack test server on port #{ port } in #{ environment } environment."

          self.thread = Thread.new {
            ENV['RAILS_ENV'] = environment.to_s
            Rack::Server.start(:config => 'config.ru', :Port => port, :AccessLog => [])
          }

        rescue Exception => e
          ::Guard::UI.error "Cannot start Rack server: #{ e.message }"
        end

        # Start the Jasmine gem server of the current project.
        #
        # @param [Number] port the server port
        #
        def start_jasmine_gem_server(port)
          require 'jasmine'
          require 'jasmine/config'

          jasmine_config_overrides = File.join(::Jasmine::Config.new.project_root, 'spec', 'javascripts' ,'support' ,'jasmine_config.rb')
          require jasmine_config_overrides if File.exist?(jasmine_config_overrides)

          ::Guard::UI.info "Guard::Jasmine starts Jasmine Gem test server on port #{ port }."

          self.thread = Thread.new { ::Jasmine::Config.new.start_server(port) }

        rescue Exception => e
          ::Guard::UI.error "Cannot start Jasmine Gem server: #{ e.message }"
        end

        # Detect the server to use
        #
        # @return [Symbol] the server strategy
        #
        def detect_server
          if File.exists?('config.ru')
            :rack
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
              return
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
