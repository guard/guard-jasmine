source 'http://rubygems.org'

# Specify your gem's dependencies in guard-jasmine.gemspec
gemspec

gem 'rake'
gem 'jasmine'

require 'rbconfig'

if RbConfig::CONFIG['target_os'] =~ /darwin/i
  gem 'rb-fsevent', '>= 0.4.0'
  gem 'growl',      '~> 1.0.3'
end
if RbConfig::CONFIG['target_os'] =~ /linux/i
  gem 'rb-inotify', '>= 0.8.4'
  gem 'libnotify',  '~> 0.3.0'
end
