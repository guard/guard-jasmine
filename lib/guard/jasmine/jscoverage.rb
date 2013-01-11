# coding: utf-8
require 'tilt'
class JasmineCoverage < Tilt::Template
  def prepare
  end

  def evaluate(context, locals)
    return data unless file.include?(Rails.root.to_s)
    return data unless file.include?(Rails.root.join('app', 'assets').to_s)
    filename = File.basename(file, '.coffee')
    puts "Generating jscoverage instrumented file for #{file.gsub(Rails.root.to_s, '')}"
    Dir.mktmpdir do |path|
      Dir.mkdir File.join(path, 'in')
      File.write File.join(path, 'in', filename), data
      `jscoverage --encoding=UTF-8 #{path}/in #{path}/out`
      raise "Could not genrate jscoverage instrumented file for #{file}" unless $?.success?
      File.read File.join(path, 'out', filename)
    end
  end
end

if ENV['JSCOVERAGE'] == 'true' and defined?(Rails)
  class GuardJasmineCoverageEngine < Rails::Engine
    config.after_initialize do |app|
      app.assets.register_postprocessor 'application/javascript', JasmineCoverage
    end
  end
end
