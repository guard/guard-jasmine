require 'rspec'

require 'guard/compat/test/helper'
require 'guard/jasmine'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.color = true
  config.filter_run focus: ENV["CI"] != "true"
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!
  config.default_formatter = "doc"

  config.order = :random
  Kernel.srand config.seed

  config.raise_errors_for_deprecations!

  config.before(:each) do
    ENV['GUARD_ENV'] = 'test'
    @project_path    = Pathname.new(File.expand_path('../../', __FILE__))

    allow(Guard::UI).to receive(:info)
    allow(Guard::UI).to receive(:debug)
    allow(Guard::UI).to receive(:error)
    allow(Guard::UI).to receive(:warning)
    allow(Guard::UI).to receive(:color_enabled?).and_return(true)
  end

  config.after(:each) do
    ENV['GUARD_ENV'] = nil
  end
end
