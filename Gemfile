source 'https://rubygems.org'

gemspec development_group: :gem_build_tools

group :development do
  gem 'coolline'
  gem 'rb-fsevent'
  gem 'redcarpet'
  gem 'yajl-ruby'
  gem 'rubocop'

  gem 'guard-coffeescript', '~> 2.0'
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
