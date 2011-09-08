require 'spec_helper'

describe Guard::Jasmine do

  let(:guard) { Guard::Jasmine.new }

  let(:runner) { Guard::Jasmine::Runner }
  let(:inspector) { Guard::Jasmine::Inspector }
  let(:formatter) { Guard::Jasmine::Formatter }

  before do
    inspector.stub(:clean)
    runner.stub(:run)
    formatter.stub(:notify)
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
    context 'with the Jasmine runner available' do
      let(:http) { mock('http') }

      before do
        http.stub_chain(:request, :code).and_return 200
        Net::HTTP.stub(:start).and_yield http
      end

      it 'does show that the runner is available' do
        formatter.should_receive(:info).with "Jasmine test runner is available at http://localhost:3000/jasmine"
        guard.start
      end
    end

    context 'without the Jasmine runner available' do
      let(:http) { mock('http') }

      before do
        http.stub_chain(:request, :code).and_return 404
        Net::HTTP.stub(:start).and_yield http
      end

      it 'does show that the runner is not available' do
        formatter.should_receive(:error).with "Jasmine test runner not available at http://localhost:3000/jasmine"
        guard.start
      end

      context 'with notifications enabled' do
        it 'shows a failing system notification' do
          formatter.should_receive(:notify).with("Jasmine test runner not available at http://localhost:3000/jasmine",
                                                 :title    => 'Jasmine test runner',
                                                 :image    => :failed,
                                                 :priority => 2)
          guard.start
        end
      end
    end

    context 'with :all_on_start set to true' do
      let(:guard) { Guard::Jasmine.new(nil, { :all_on_start => true }) }

      context 'with the Jasmine runner available' do
        before do
          guard.stub(:jasmine_runner_available?).and_return true
        end

        it 'triggers .run_all' do
          guard.should_receive(:run_all)
          guard.start
        end
      end

      context 'without the Jasmine runner available' do
        before do
          guard.stub(:jasmine_runner_available?).and_return false
        end

        it 'does not triggers .run_all' do
          guard.should_not_receive(:run_all)
          guard.start
        end
      end
    end

    context 'with :all_on_start set to false' do
      let(:guard) { Guard::Jasmine.new(nil, { :all_on_start => false }) }

      before do
        guard.stub(:jasmine_runner_available?).and_return true
      end

      it 'does not trigger .run_all' do
        guard.should_not_receive(:run_all)
        guard.start
      end
    end
  end

  describe '.run_all' do
    it 'starts the Runner with the spec dir' do
      runner.should_receive(:run).with(['spec/javascripts'], {
          :jasmine_url   => 'http://localhost:3000/jasmine',
          :phantomjs_bin => '/usr/local/bin/phantomjs',
          :all_on_start  => true,
          :notification  => true,
          :hide_success  => false }).and_return [['spec/javascripts/a.js.coffee'], true]

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
