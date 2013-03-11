require 'net/http'
require 'timeout'
require 'guard/jasmine/formatter'

module Guard
  class Jasmine

    # Provider of some shared utility methods.
    #
    module Util

      # Verifies if the Jasmine test runner is available.
      # If the runner is not available within 15 seconds, then
      # the availability check will cancel.
      #
      # @param [Hash] options the options for the Guard
      # @option options [Integer] :server_timeout the number of seconds to wait for the Jasmine spec server
      # @option options [String] :jasmine_url the url of the Jasmine test runner
      # @return [Boolean] when the runner is available
      #
      def runner_available?(options)
        url = URI.parse(options[:jasmine_url])

        begin
          ::Guard::Jasmine::Formatter.info "Waiting for Jasmine test runner at #{ url }"

          http = Net::HTTP.new(url.host, url.port)
          http.read_timeout = options[:server_timeout]
          http.start do
            response  = http.request(Net::HTTP::Get.new(url.path))
            available = response.code.to_i == 200

            unless available
              ::Guard::Jasmine::Formatter.error "Jasmine test runner failed with status #{ response.code }"
              if response.body
                ::Guard::Jasmine::Formatter.error 'Please open the Jasmine runner in your browser for more information.'
              end
            end

            available
          end

        rescue Timeout::Error => e
          ::Guard::Jasmine::Formatter.error 'Timeout waiting for the Jasmine test runner.'
          false

        rescue => e
          ::Guard::Jasmine::Formatter.error "Jasmine test runner isn't available: #{ e.message }"
          false
        end
      end

      # Verifies that the phantomjs bin is available and the
      # right version is installed.
      #
      # @param [String] bin the location of the phantomjs bin
      # @return [Boolean] when the runner is available
      #
      def phantomjs_bin_valid?(bin)
        if bin && !bin.empty?
          version = `#{ bin } --version`

          if version
            # Remove all but version, e.g. from '1.5 (development)'
            cleaned_version = version.match(/(\d\.)*(\d)/)

            if cleaned_version
              if Gem::Version.new(cleaned_version[0]) < Gem::Version.new('1.3.0')
                ::Guard::Jasmine::Formatter.error "PhantomJS executable at #{ bin } must be at least version 1.3.0"
              else
                true
              end
            else
              ::Guard::Jasmine::Formatter.error "PhantomJS reports unknown version format: #{ version }"
            end
          else
            ::Guard::Jasmine::Formatter.error "PhantomJS executable doesn't exist at #{ bin }"
          end
        else
          ::Guard::Jasmine::Formatter.error 'PhantomJS executable couldn\'t be auto detected.'
        end
      end

      # Finds a free server port to use
      #
      # @return [Integer] a free server port
      #
      def find_free_server_port
        server = TCPServer.new('127.0.0.1', 0)
        port   = server.addr[1]
        server.close

        port
      rescue Errno::EADDRINUSE
        retry
      end

      # Cross-platform way of finding an executable in the $PATH.
      # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
      #
      # @example
      #   which('ruby') #=> /usr/bin/ruby
      #
      # @param cmd [String] the executable to find
      # @return [String, nil] the path to the executable
      #
      def which(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = "#{ path }/#{ cmd }#{ ext }"
            return exe if File.executable?(exe)
          end
        end

        nil
      end

    end

  end
end
