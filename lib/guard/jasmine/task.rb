#!/usr/bin/env ruby

require 'rake'
require 'rake/tasklib'

require 'guard/jasmine/cli'

module Guard

  # Provides a method to define a Rake task that
  # runs the Jasmine specs.
  #
  class JasmineTask < ::Rake::TaskLib

    # Name of the main, top level task
    attr_accessor :name

    # CLI options
    attr_accessor :options

    # Initialize the Rake task
    #
    # @param [Symbol] name the name of the Rake task
    # @param [String] options the CLI options
    # @yield [JasmineTask] the task
    #
    def initialize(name = :jasmine, options = '')
      @name = name
      @options = options

      yield self if block_given?

      namespace :guard do
        desc 'Run all Jasmine specs'
        new_task = task(name) do
          begin
            ::Guard::Jasmine::CLI.start(options.split)

          rescue SystemExit => e
            case e.status
            when 1
              fail 'Some specs have failed'
            when 2
              fail "The spec couldn't be run: #{ e.message }'"
            end
          end
        end

        new_task.execute
      end
    end

  end
end
