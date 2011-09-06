require 'spec_helper'

describe Guard::Jasmine::Runner do

  let(:runner) { Guard::Jasmine::Runner }

  describe '#run' do
    context "when passed an empty paths list" do
      it "returns false" do
        runner.run([]).should be_false
      end
    end
  end

end
