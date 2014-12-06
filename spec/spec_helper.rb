require 'rspec'

require 'guard/compat/test/helper'
require 'guard/jasmine'

RSpec.configure do |config|

  config.color = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    ENV['GUARD_ENV'] = 'test'
    @project_path    = Pathname.new(File.expand_path('../../', __FILE__))

    allow(Guard::UI).to receive(:info)
    allow(Guard::UI).to receive(:debug)
    allow(Guard::UI).to receive(:error)
    allow(Guard::UI).to receive(:success)
    allow(Guard::UI).to receive(:warning)
    allow(Guard::UI).to receive(:notify)
    allow(Guard::UI).to receive(:color_enabled?).and_return(true)
  end

  config.after(:each) do
    ENV['GUARD_ENV'] = nil
  end
end
