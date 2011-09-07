require 'spec_helper'

describe Guard::Jasmine do

  before do
    Guard::Jasmine::Inspector.stub(:clean)
    Guard::Jasmine::Runner.stub(:run)
  end

  describe '#initialize' do
    context 'when no options are provided' do
      let(:guard) { Guard::Jasmine.new }

      it 'sets a default :jasmine_url option' do
        guard.options[:jasmine_url].should eql 'http://localhost:3000/jasmine'
      end

      it 'sets a default :phantomjs_bin option' do
        guard.options[:phantomjs_bin].should eql '/usr/local/bin/phantomjs'
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
                                                  :notification => false,
                                                  :hide_success  => true }) }

      it 'sets a default :jasmine_url option' do
        guard.options[:jasmine_url].should eql 'http://192.168.1.5/jasmine'
      end

      it 'sets a default :phantomjs_bin option' do
        guard.options[:phantomjs_bin].should eql '~/bin/phantomjs'
      end

      it 'sets a default :notifications option' do
        guard.options[:notification].should be_false
      end

      it 'sets a default :hide_success option' do
        guard.options[:hide_success].should be_true
      end
    end
  end

  describe '.run_all' do
    let(:guard) { Guard::Jasmine.new([Guard::Watcher.new('^spec/javascripts/x/(.+)\.js.coffee')]) }

    before do
      Dir.stub(:glob).and_return ['spec/javascripts/x/a.js.coffee',
                                  'spec/javascripts/x/b.js.coffee',
                                  'spec/javascripts/y/c.js.coffee']
    end

    it 'runs the run_on_change with all watched CoffeeScripts' do
      guard.should_receive(:run_on_change).with(['spec/javascripts/x/a.js.coffee', 'spec/javascripts/x/b.js.coffee'])
      guard.run_all
    end
  end

  describe '.run_on_change' do
    let(:guard) { Guard::Jasmine.new }

    before do
      guard.stub(:notify)
    end

    it 'passes the paths to the Inspector for cleanup' do
      Guard::Jasmine::Inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js.coffee'])
      guard.run_on_change(['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js.coffee'])
    end

    it 'starts the Runner with the cleaned files' do
      Guard::Jasmine::Inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                                                 'spec/javascripts/b.js.coffee']).and_return ['spec/javascripts/a.js.coffee']
      Guard::Jasmine::Runner.should_receive(:run).with(['spec/javascripts/a.js.coffee'], {
          :jasmine_url   => 'http://localhost:3000/jasmine',
          :phantomjs_bin => '/usr/local/bin/phantomjs',
          :notification => true,
          :hide_success  => false }).and_return [['spec/javascripts/a.js.coffee'], true]
      guard.run_on_change(['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js.coffee'])
    end

  end
end
