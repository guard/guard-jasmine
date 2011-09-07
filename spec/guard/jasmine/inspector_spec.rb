require 'spec_helper'

describe Guard::Jasmine::Inspector do
  before do
    Dir.stub(:glob).and_return ['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js']
  end

  subject { Guard::Jasmine::Inspector }

  describe 'clean' do
    it 'removes duplicate files' do
      subject.clean(['spec/javascripts/a.js.coffee', 'spec/javascripts/a.js.coffee']).should == ['spec/javascripts/a.js.coffee']
    end

    it 'remove nil files' do
      subject.clean(['spec/javascripts/a.js.coffee', nil]).should == ['spec/javascripts/a.js.coffee']
    end

    it 'removes files that are no javascript specs' do
      subject.clean(['spec/javascripts/a.js.coffee',
                     'spec/javascripts/b.js',
                     'app/assets/javascripts/a.js.coffee',
                     'b.txt']).should == ['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js']
    end

    it 'frees up the list of specs' do
      subject.should_receive(:clear_jasmine_specs)
      subject.clean(['spec/javascripts/a.js.coffee'])
    end

  end
end
