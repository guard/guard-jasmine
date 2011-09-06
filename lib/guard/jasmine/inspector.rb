module Guard
  class Jasmine
    module Inspector
      class << self

        def clean(paths)
          paths.uniq!
          paths.compact!
          paths = paths.select { |p| jasmine_spec?(p) }
          clear_jasmine_specs
          paths
        end

        private

        def jasmine_spec?(path)
          jasmine_specs.include?(path)
        end

        def jasmine_specs
          @jasmine_specs ||= Dir.glob('spec/**/*_spec.js(.coffee)?')
        end

        def clear_jasmine_specs
          @jasmine_specs = nil
        end

      end
    end
  end
end
