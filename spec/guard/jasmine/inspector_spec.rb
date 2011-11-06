require 'spec_helper'

describe Guard::Jasmine::Inspector do
  before do
    Dir.stub(:glob).and_return ['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js', 'c.coffee']
  end

  subject { Guard::Jasmine::Inspector }

  describe 'clean' do
    it 'allows the Jasmine spec dir' do
      subject.clean(['spec/javascripts', 'spec/javascripts/a.js.coffee']).should == ['spec/javascripts']
    end

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
                     'b.txt',
                     'c.coffee']).should == ['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js', 'c.coffee']
    end

  end
end
