require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

def ci?
  ENV['CI'] == 'true'
end

default_tasks = []

default_tasks << RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = ci?
end

unless ci?
  require 'rubocop/rake_task'
  default_tasks << RuboCop::RakeTask.new(:rubocop)
end

task default: default_tasks.map(&:name)

namespace(:spec) do
  desc 'Run all specs on multiple ruby versions (requires rvm)'
  task(:portability) do
    travis_config_file = File.expand_path('../.travis.yml', __FILE__)
    begin
      travis_options ||= YAML.load_file(travis_config_file)
    rescue => ex
      puts "Travis config file '#{travis_config_file}' could not be found: #{ex.message}"
      return
    end

    travis_options['rvm'].each do |version|
      system <<-BASH
        bash -c 'source ~/.rvm/scripts/rvm;
                 rvm #{version};
                 ruby_version_string_size=`ruby -v | wc -m`
                 echo;
                 for ((c=1; c<$ruby_version_string_size; c++)); do echo -n "="; done
                 echo;
                 echo "`ruby -v`";
                 for ((c=1; c<$ruby_version_string_size; c++)); do echo -n "="; done
                 echo;
                 RBXOPT="-Xrbc.db" bundle install;
                 RBXOPT="-Xrbc.db" bundle exec rspec spec -f doc 2>&1;'
      BASH
    end
  end
end
