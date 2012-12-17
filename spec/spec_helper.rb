require 'rspec'
require 'guard/jasmine'

RSpec.configure do |config|

  config.color_enabled = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    ENV["GUARD_ENV"] = 'test'
    @project_path    = Pathname.new(File.expand_path('../../', __FILE__))
    
    Guard::UI.stub(:info)
    Guard::UI.stub(:debug)
    Guard::UI.stub(:error)
    Guard::UI.stub(:success)
    Guard::UI.stub(:warning)
    Guard::UI.stub(:notify)
  end

  config.after(:each) do
    ENV["GUARD_ENV"] = nil
  end
end
