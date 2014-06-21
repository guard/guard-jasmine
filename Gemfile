source 'https://rubygems.org'

gemspec

gem 'rake'

gem 'rack'
gem 'jasmine'

gem 'guard-coffeescript'
gem 'guard-shell'
gem 'guard-rspec'
gem 'rspec', '~> 2.14.1'
gem 'tilt'

unless ENV['TRAVIS']
  gem 'coolline'
  gem 'rb-fsevent'
  gem 'redcarpet'
  gem 'pry'
  gem 'yard'
  gem 'yajl-ruby'
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end