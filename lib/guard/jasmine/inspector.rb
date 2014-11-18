module Guard
  class Jasmine

    # The inspector verifies if the changed paths are valid
    # for Guard::Jasmine. Please note that request to {.clean}
    # paths keeps the current valid files cached until {.clear} is
    # called.
    #
    module Inspector
      class << self

        # Clean the changed paths and return only valid
        # Jasmine specs in either JavaScript or CoffeeScript.
        #
        # @param [Array<String>] paths the changed paths
        # @param [Hash] options the options for the Guard
        # @option options [String] :spec_dir the directory with the Jasmine specs
        # @return [Array<String>] the valid spec files
        #
        def clean(paths, options)
          paths.uniq!
          paths.compact!
          if paths.include?(options[:spec_dir])
            paths = [options[:spec_dir]]
          else
            paths = paths.select { |p| jasmine_spec?(p) }
          end

          paths
        end

        private

        # Tests if the file is valid.
        #
        # @param [String] path the file
        # @return [Boolean] when the file valid
        #
        def jasmine_spec?(path)
          path =~ /(?:_s|S)pec\.(js|coffee|js\.coffee)$/ && File.exists?(path)
        end

      end
    end
  end
end
