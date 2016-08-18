require 'rspec'
require 'pathname'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.color = true
  config.filter_run focus: ENV['CI'] != 'true'
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!
  config.default_formatter = 'doc'

  config.order = :random
  Kernel.srand config.seed

  config.raise_errors_for_deprecations!

  config.before(:each) do
    @project_path = Pathname.new(File.expand_path('../../', __FILE__))
  end
end
