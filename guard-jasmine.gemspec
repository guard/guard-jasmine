# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/jasmine/version'

Gem::Specification.new do |s|
  s.name        = 'guard-jasmine'
  s.version     = Guard::JasmineVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Michael Kessler']
  s.email       = ['michi@netzpiraten.ch']
  s.homepage    = 'https://github.com/netzpirat/guard-jasmine'
  s.summary     = 'Guard gem for headless testing with Jasmine'
  s.description = 'Guard::Jasmine automatically tests your Jasmine specs on PhantomJS'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = 'guard-jasmine'

  s.add_dependency 'guard',        '>= 0.8.3'
  s.add_dependency 'multi_json'
  s.add_dependency 'childprocess'
  s.add_dependency 'thor'

  s.add_development_dependency 'bundler'

  s.files        = Dir.glob('{bin,lib}/**/*') + %w[LICENSE README.md]
  s.executables  = ['guard-jasmine', 'guard-jasmine-debug']
  s.require_path = 'lib'
end
