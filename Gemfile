source 'https://rubygems.org'

gemspec development_group: :gem_build_tools

group :development do
  gem 'coolline'
  gem 'rb-fsevent'
  gem 'redcarpet'
  gem 'yajl-ruby'
  gem 'rubocop', github: 'bbatsov/rubocop', branch: 'master'
  gem 'guard-coffeescript', github: 'guard/guard-coffeescript', branch: 'master', require: false
  gem 'guard-rspec', require: false
  gem 'guard-shell', require: false

  gem 'rack'
  gem 'yard'
end

group :test, :development do
  gem 'rake'
  gem 'rspec', '~> 3.1'
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
