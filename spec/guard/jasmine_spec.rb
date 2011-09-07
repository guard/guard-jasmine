require 'spec_helper'

describe Guard::Jasmine do

  let(:guard) { Guard::Jasmine.new }

  let(:runner) { Guard::Jasmine::Runner }
  let(:inspector) { Guard::Jasmine::Inspector }

  before do
    inspector.stub(:clean)
    runner.stub(:run)
    guard.stub(:notify)
  end

  describe '#initialize' do
    context 'when no options are provided' do
      it 'sets a default :jasmine_url option' do
        guard.options[:jasmine_url].should eql 'http://localhost:3000/jasmine'
      end

      it 'sets a default :phantomjs_bin option' do
        guard.options[:phantomjs_bin].should eql '/usr/local/bin/phantomjs'
      end

      it 'sets a default :all_on_start option' do
        guard.options[:all_on_start].should be_true
      end

      it 'sets a default :notifications option' do
        guard.options[:notification].should be_true
      end

      it 'sets a default :hide_success option' do
        guard.options[:hide_success].should be_false
      end
    end

    context 'with other options than the default ones' do
      let(:guard) { Guard::Jasmine.new(nil, { :jasmine_url   => 'http://192.168.1.5/jasmine',
                                              :phantomjs_bin => '~/bin/phantomjs',
                                              :all_on_start  => false,
                                              :notification  => false,
                                              :hide_success  => true }) }

      it 'sets the :jasmine_url option' do
        guard.options[:jasmine_url].should eql 'http://192.168.1.5/jasmine'
      end

      it 'sets the :phantomjs_bin option' do
        guard.options[:phantomjs_bin].should eql '~/bin/phantomjs'
      end

      it 'sets the :all_on_start option' do
        guard.options[:all_on_start].should be_false
      end

      it 'sets the :notifications option' do
        guard.options[:notification].should be_false
      end

      it 'sets the :hide_success option' do
        guard.options[:hide_success].should be_true
      end
    end
  end

  describe '.start' do
    context 'with :all_on_start set to true' do
      let(:guard) { Guard::Jasmine.new(nil, { :all_on_start => true }) }

      it 'triggers .run_all' do
        guard.should_receive(:run_all)
        guard.start
      end
    end

    context 'with :all_on_start set to false' do
      let(:guard) { Guard::Jasmine.new(nil, { :all_on_start => false }) }

      it 'does not trigger .run_all' do
        guard.should_not_receive(:run_all)
        guard.start
      end
    end
  end

  describe '.run_all' do
    it 'runs the run_on_change with the spec dir' do
      guard.should_receive(:run_on_change).with(['spec/javascripts'])
      guard.run_all
    end
  end

  describe '.run_on_change' do
    it 'passes the paths to the Inspector for cleanup' do
      inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                             'spec/javascripts/b.js.coffee'])

      guard.run_on_change(['spec/javascripts/a.js.coffee',
                           'spec/javascripts/b.js.coffee'])
    end

    it 'starts the Runner with the cleaned files' do
      inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                             'spec/javascripts/b.js.coffee']).and_return ['spec/javascripts/a.js.coffee']

      runner.should_receive(:run).with(['spec/javascripts/a.js.coffee'], {
          :jasmine_url   => 'http://localhost:3000/jasmine',
          :phantomjs_bin => '/usr/local/bin/phantomjs',
          :all_on_start  => true,
          :notification  => true,
          :hide_success  => false }).and_return [['spec/javascripts/a.js.coffee'], true]

      guard.run_on_change(['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js.coffee'])
    end

  end
end
