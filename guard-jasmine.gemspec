# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/jasmine/version'

Gem::Specification.new do |s|
  s.name        = 'guard-jasmine'
  s.version     = Guard::JasmineVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Michael Kessler']
  s.email       = ['michi@netzpiraten.ch']
  s.homepage    = 'http://github.com/netzpirat/guard-jasmine'
  s.summary     = 'Guard gem for headless testing with Jasmine'
  s.description = 'Guard::Jasmine automatically tests your Jasmine specs on PhantomJS'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = 'guard-jasmine'

  s.add_dependency 'guard', '>= 0.4'
  s.add_dependency 'multi_json', '~> 1.0.3'

  s.add_development_dependency 'bundler',     '~> 1.0'
  s.add_development_dependency 'guard-rspec', '~> 0.4'
  s.add_development_dependency 'rspec',       '~> 2.6'
  s.add_development_dependency 'yard',        '~> 0.7.2'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE.MIT LICENSE.BSD README.md]
  s.require_path = 'lib'
end
