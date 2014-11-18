# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/jasmine/version'

Gem::Specification.new do |s|
  s.name        = 'guard-jasmine'
  s.version     = Guard::JasmineVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Michael Kessler', "Nathan Stitt"]
  s.email       = ['michi@flinkfinger.com', 'nathan@stitt.org']
  s.homepage    = 'https://github.com/netzpirat/guard-jasmine'
  s.summary     = 'Guard gem for headless testing with Jasmine'
  s.description = 'Guard::Jasmine automatically tests your Jasmine specs on PhantomJS'
  s.license     = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = 'guard-jasmine'

  s.add_dependency 'guard',       '~> 2.8'
  s.add_dependency 'jasmine',     '>= 2.0.2'
  s.add_dependency 'multi_json'
  s.add_dependency 'childprocess'
  s.add_dependency 'thor'
  s.add_dependency 'tilt'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'

  s.add_development_dependency 'rack'

  s.add_development_dependency 'guard-coffeescript'
  s.add_development_dependency 'guard-shell'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'pry-plus'
  s.add_development_dependency 'yard'

  s.files        = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md]
  s.executables  = ['guard-jasmine', 'guard-jasmine-debug']
  s.require_path = 'lib'
end
