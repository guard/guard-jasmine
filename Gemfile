source 'https://rubygems.org'

gemspec

unless ENV['TRAVIS']
  gem 'coolline'
  gem 'rb-fsevent'
  gem 'redcarpet'
  gem 'yajl-ruby'
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
