source 'https://rubygems.org'

gemspec

unless ENV['TRAVIS']
  gem 'coolline'
  gem 'rb-fsevent'
  gem 'redcarpet'
  gem 'yajl-ruby'
  gem 'rubocop', github: 'bbatsov/rubocop', branch: 'master'
  gem 'guard-coffeescript', github: 'guard/guard-coffeescript', branch: 'master', require: false
  gem 'guard-rspec', require: false
  gem 'guard-shell', require: false
end

group :test do
  gem 'rspec', '~> 3.1'
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
