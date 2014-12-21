source 'https://rubygems.org'

gemspec development_group: :gem_build_tools

group :development do
  gem 'coolline'
  gem 'rb-fsevent'
  gem 'redcarpet'
  gem 'yajl-ruby'
  gem 'rubocop', github: 'bbatsov/rubocop', branch: 'master'

  # Not released yet
  # gem 'guard-coffeescript', '~> 2.0'
  gem 'guard-coffeescript', github: 'guard/guard-coffeescript', ref: 'dd6c4f323'

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
