# coding: utf-8
require 'tilt'
require 'childprocess'
require 'guard/jasmine'
require 'guard/jasmine/util'

# Tilt template to generate coverage instrumented
# Jasmine specs files.
#
class JasmineCoverage < Tilt::Template
  extend ::Guard::Jasmine::Util

  def prepare
  end

  # Returns a coverage instrumented JavaScript file
  #
  def evaluate(_context, _locals)
    return data if !ENV['IGNORE_INSTRUMENTATION'].to_s.empty? && file =~ Regexp.new(ENV['IGNORE_INSTRUMENTATION'])
    return data unless JasmineCoverage.coverage_bin
    return data unless file.include?(JasmineCoverage.app_asset_path)

    Dir.mktmpdir do |path|
      filename = File.basename(file)
      input    = File.join(path, filename).sub(/\.js.+/, '.js')

      File.write input, data

      result = `#{JasmineCoverage.coverage_bin} instrument --embed-source #{input.shellescape}`

      raise "Could not generate coverage instrumented file for #{file}" unless $CHILD_STATUS.exitstatus.zero?

      result.gsub input, file
    end
  end

  # Get the absolute path to the projects assets path `/app/assets`.
  #
  # @return [String] the path to the Rails assets
  #
  # @private
  def self.app_asset_path
    @app_asset_path ||= File.join(Rails.root, 'app', 'assets')
  end

  # Returns the coverage executable path.
  #
  # @return [String] the path
  #
  # @private
  def self.coverage_bin
    @coverage_bin ||= which 'istanbul'
  end
end

if ENV['COVERAGE'] == 'true' && defined?(Rails)

  # Guard::Jasmine engine to register coverage instrumented
  # Jasmine spec files.
  #
  class GuardJasmineCoverageEngine < ::Rails::Engine
    initializer 'guard-jasmine.initialize' do |app|
      app.config.assets.configure do |env|
        env.register_postprocessor 'application/javascript', JasmineCoverage
      end
    end
  end

end
