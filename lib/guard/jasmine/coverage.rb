# coding: utf-8
require 'tilt'
require 'childprocess'
require 'guard/jasmine/util'

# Tilt template to generate coverage instrumented
# Jasmine specs files.
#
class JasmineCoverage < Tilt::Template
  extend ::Guard::Jasmine::Util

  def prepare
  end

  # Returns a coverage instrumented JavaScript file
  # when the environment variable `JSCOVERAGE` is `true`
  # and the `jscoverage` binary is in the `$PATH`.
  #
  def evaluate(context, locals)
    return data unless JasmineCoverage.coverage_bin
    return data unless file.include?(JasmineCoverage.app_asset_path)

    Dir.mktmpdir do |path|
      filename = File.basename(file)
      input    = File.join(path, filename).sub /\.js.+/, '.js'

      File.write input, data

      r, w = IO.pipe
      proc = ChildProcess.build(JasmineCoverage.coverage_bin, 'instrument', '--embed-source', input)
      proc.io.stdout = proc.io.stderr = w
      proc.start
      proc.wait
      w.close

      raise "Could not generate coverage instrumented file for #{ file }" unless proc.exit_code == 0

      r.read.gsub input, file
    end
  end

  private

  # Get the absolute path to the projects assets path `/app/assets`.
  #
  # @return [String] the path to the Rails assets
  #
  def self.app_asset_path
    @app_asset_path ||= File.join(Rails.root, 'app', 'assets')
  end

  # Returns the coverage executable path.
  #
  # @return [String] the path
  #
  def self.coverage_bin
    @coverage_bin ||= which 'istanbul'
  end

end

if ENV['COVERAGE'] == 'true' and defined?(Rails)

  # Guard::Jasmine engine to register coverage instrumented
  # Jasmine spec files.
  #
  class GuardJasmineCoverageEngine < ::Rails::Engine
    config.after_initialize do |app|
      app.assets.register_postprocessor 'application/javascript', JasmineCoverage
    end
  end

end
