require 'spec_helper'

describe Guard::Jasmine do

  let(:guard) { Guard::Jasmine.new }

  let(:runner) { Guard::Jasmine::Runner }
  let(:inspector) { Guard::Jasmine::Inspector }
  let(:formatter) { Guard::Jasmine::Formatter }
  let(:server) { Guard::Jasmine::Server }

  let(:defaults) { Guard::Jasmine::DEFAULT_OPTIONS }

  before do
    inspector.stub(:clean).and_return { |specs| specs }
    runner.stub(:run).and_return [true, []]
    formatter.stub(:notify)
    server.stub(:start)
    server.stub(:stop)
    Guard::Jasmine.stub(:which).and_return '/usr/local/bin/phantomjs'
  end

  describe '#initialize' do
    context 'when no options are provided' do
      it 'sets a default :server option' do
        guard.options[:server].should eql :auto
      end

      it 'sets a default :server option' do
        guard.options[:server_env].should eql 'development'
      end

      it 'sets a default :port option' do
        guard.options[:port].should eql 8888
      end

      it 'sets a default :jasmine_url option' do
        guard.options[:jasmine_url].should eql 'http://localhost:8888/jasmine'
      end

      it 'sets a default :timeout option' do
        guard.options[:timeout].should eql 10000
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

      it 'sets a default :max_error_notify option' do
        guard.options[:max_error_notify].should eql 3
      end

      it 'sets a default :keep_failed option' do
        guard.options[:keep_failed].should be_true
      end

      it 'sets a default :all_after_pass option' do
        guard.options[:all_after_pass].should be_true
      end

      it 'sets a default :specdoc option' do
        guard.options[:specdoc].should eql :failure
      end

      it 'sets a default :console option' do
        guard.options[:console].should eql :failure
      end

      it 'sets a default :focus option' do
        guard.options[:focus].should eql true
      end

      it 'sets last run failed to false' do
        guard.last_run_failed.should be_false
      end

      it 'sets last failed paths to empty' do
        guard.last_failed_paths.should be_empty
      end

      it 'tries to auto detect the :phantomjs_bin' do
        ::Guard::Jasmine.should_receive(:which).and_return '/bin/phantomjs'
        guard.options[:phantomjs_bin].should eql '/bin/phantomjs'
      end
    end

    context 'with other options than the default ones' do
      let(:guard) { Guard::Jasmine.new(nil, { :server           => :jasmine_gem,
                                              :server_env       => 'test',
                                              :port             => 4321,
                                              :jasmine_url      => 'http://192.168.1.5/jasmine',
                                              :phantomjs_bin    => '~/bin/phantomjs',
                                              :timeout          => 20000,
                                              :all_on_start     => false,
                                              :notification     => false,
                                              :max_error_notify => 5,
                                              :hide_success     => true,
                                              :keep_failed      => false,
                                              :all_after_pass   => false,
                                              :specdoc          => :always,
                                              :focus            => false,
                                              :console          => :always }) }

      it 'sets the :server option' do
        guard.options[:server].should eql :jasmine_gem
      end

      it 'sets the :server_env option' do
        guard.options[:server_env].should eql 'test'
      end

      it 'sets the :jasmine_url option' do
        guard.options[:port].should eql 4321
      end

      it 'sets the :jasmine_url option' do
        guard.options[:jasmine_url].should eql 'http://192.168.1.5/jasmine'
      end

      it 'sets the :phantomjs_bin option' do
        guard.options[:phantomjs_bin].should eql '~/bin/phantomjs'
      end

      it 'sets the :phantomjs_bin option' do
        guard.options[:timeout].should eql 20000
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

      it 'sets the :max_error_notify option' do
        guard.options[:max_error_notify].should eql 5
      end

      it 'sets the :keep_failed option' do
        guard.options[:keep_failed].should be_false
      end

      it 'sets the :all_after_pass option' do
        guard.options[:all_after_pass].should be_false
      end

      it 'sets the :specdoc option' do
        guard.options[:specdoc].should eql :always
      end

      it 'sets the :console option' do
        guard.options[:console].should eql :always
      end

      it 'sets the :focus option' do
        guard.options[:focus].should eql false
      end
    end

    context 'with a port but no jasmine_url option set' do
      let(:guard) { Guard::Jasmine.new(nil, { :port => 4321 }) }

      it 'sets the port on the jasmine_url' do
        guard.options[:jasmine_url].should eql 'http://localhost:4321/jasmine'
      end
    end

    context 'with illegal options' do
      let(:guard) { Guard::Jasmine.new(nil, defaults.merge({ :specdoc => :wrong, :server => :unknown })) }

      it 'sets default :specdoc option' do
        guard.options[:specdoc].should eql :failure
      end

      it 'sets default :server option' do
        guard.options[:server].should eql :auto
      end
    end
  end

  describe '.start' do
    context 'without a valid PhantomJS executable' do

      before do
        Guard::Jasmine.stub(:phantomjs_bin_valid?).and_return false
      end

      it 'throws :task_has_failed' do
        expect { guard.start }.to throw_symbol :task_has_failed
      end
    end

    context 'with a valid PhantomJS executable' do
      let(:guard) { Guard::Jasmine.new(nil, { :phantomjs_bin => '/bin/phantomjs' }) }

      before do
        ::Guard::Jasmine.stub(:phantomjs_bin_valid?).and_return true
      end

      context 'with the server set to :none' do
        before { guard.options[:server] = :none }

        it 'does not start a server' do
          server.should_not_receive(:start)
          guard.start
        end
      end

      context 'with the server set to something other than :none' do
        before do
          guard.options[:server]     = :jasmine_gem
          guard.options[:server_env] = 'test'
          guard.options[:port]       = 3333
        end

        it 'does start a server' do
          server.should_receive(:start).with(:jasmine_gem, 3333, 'test')
          guard.start
        end
      end

      context 'with :all_on_start set to true' do
        let(:guard) { Guard::Jasmine.new(nil, { :all_on_start => true }) }

        context 'with the Jasmine runner available' do
          before do
            ::Guard::Jasmine.stub(:runner_available?).and_return true
          end

          it 'triggers .run_all' do
            guard.should_receive(:run_all)
            guard.start
          end
        end

        context 'without the Jasmine runner available' do
          before do
            ::Guard::Jasmine.stub(:runner_available?).and_return false
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
          ::Guard::Jasmine.stub(:runner_available?).and_return true
        end

        it 'does not trigger .run_all' do
          guard.should_not_receive(:run_all)
          guard.start
        end
      end
    end
  end

  describe '.stop' do
    context 'with a configured server' do
      let(:guard) { Guard::Jasmine.new(nil, { :server => :thin }) }

      it 'stops the server' do
        server.should_receive(:stop)
        guard.stop
      end
    end

    context 'without a configured server' do
      let(:guard) { Guard::Jasmine.new(nil, { :server => :none }) }

      it 'does not stop the server' do
        server.should_not_receive(:stop)
        guard.stop
      end
    end
  end

  describe '.reload' do
    before do
      guard.last_run_failed   = true
      guard.last_failed_paths = ['spec/javascripts/a.js.coffee']
    end

    it 'sets last run failed to false' do
      guard.reload
      guard.last_run_failed.should be_false
    end

    it 'sets last failed paths to empty' do
      guard.reload
      guard.last_failed_paths.should be_empty
    end
  end

  describe '.run_all' do
    let(:guard) { Guard::Jasmine.new(nil, { :phantomjs_bin => '/bin/phantomjs' }) }

    it 'starts the Runner with the spec dir' do
      runner.should_receive(:run).with(['spec/javascripts'], defaults.merge(:phantomjs_bin => '/bin/phantomjs')).and_return [['spec/javascripts/a.js.coffee'], true]

      guard.run_all
    end

    context 'with all specs passing' do
      before do
        guard.last_failed_paths = ['spec/javascripts/a.js.coffee']
        guard.last_run_failed   = true
        runner.stub(:run).and_return [true, []]
      end

      it 'sets the last run failed to false' do
        guard.run_all
        guard.last_run_failed.should be_false
      end

      it 'clears the list of failed paths' do
        guard.run_all
        guard.last_failed_paths.should be_empty
      end
    end

    context 'with failing specs' do
      before do
        runner.stub(:run).and_return [false, []]
      end

      it 'throws :task_has_failed' do
        expect { guard.run_all }.to throw_symbol :task_has_failed
      end
    end

  end

  describe '.run_on_change' do
    let(:guard) { Guard::Jasmine.new(nil, { :phantomjs_bin => '/Users/michi/.bin/phantomjs' }) }

    it 'passes the paths to the Inspector for cleanup' do
      inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                             'spec/javascripts/b.js.coffee'])

      guard.run_on_change(['spec/javascripts/a.js.coffee',
                           'spec/javascripts/b.js.coffee'])
    end

    it 'returns false when no valid paths are passed' do
      inspector.should_receive(:clean).and_return []
      guard.run_on_change(['spec/javascripts/b.js.coffee'])
    end

    it 'starts the Runner with the cleaned files' do
      inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                             'spec/javascripts/b.js.coffee']).and_return ['spec/javascripts/a.js.coffee']

      runner.should_receive(:run).with(['spec/javascripts/a.js.coffee'], defaults.merge({ :phantomjs_bin => '/Users/michi/.bin/phantomjs' })).and_return [['spec/javascripts/a.js.coffee'], true]

      guard.run_on_change(['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js.coffee'])
    end

    context 'with :keep_failed enabled' do
      let(:guard) { Guard::Jasmine.new(nil, { :keep_failed => true, :phantomjs_bin => '/usr/bin/phantomjs' }) }

      before do
        guard.last_failed_paths = ['spec/javascripts/b.js.coffee']
      end

      it 'passes the paths to the Inspector for cleanup' do
        inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                               'spec/javascripts/b.js.coffee'])

        guard.run_on_change(['spec/javascripts/a.js.coffee'])
      end

      it 'appends the last failed paths to the current run' do
        runner.should_receive(:run).with(['spec/javascripts/a.js.coffee',
                                          'spec/javascripts/b.js.coffee'], defaults.merge({ :phantomjs_bin => '/usr/bin/phantomjs' }))

        guard.run_on_change(['spec/javascripts/a.js.coffee'])
      end
    end

    context 'with only success specs' do
      before do
        guard.last_failed_paths = ['spec/javascripts/a.js.coffee']
        guard.last_run_failed   = true
        runner.stub(:run).and_return [true, []]
      end

      it 'sets the last run failed to false' do
        guard.run_on_change(['spec/javascripts/a.js.coffee'])
        guard.last_run_failed.should be_false
      end

      it 'removes the passed specs from the list of failed paths' do
        guard.run_on_change(['spec/javascripts/a.js.coffee'])
        guard.last_failed_paths.should be_empty
      end

      context 'when :all_after_pass is enabled' do
        let(:guard) { Guard::Jasmine.new(nil, { :all_after_pass => true }) }

        it 'runs all specs' do
          guard.should_receive(:run_all)
          guard.run_on_change(['spec/javascripts/a.js.coffee'])
        end
      end

      context 'when :all_after_pass is enabled' do
        let(:guard) { Guard::Jasmine.new(nil, { :all_after_pass => false }) }

        it 'does not run all specs' do
          guard.should_not_receive(:run_all)
          guard.run_on_change(['spec/javascripts/a.js.coffee'])
        end
      end
    end

    context 'with failing specs' do
      before do
        guard.last_run_failed = false
        runner.stub(:run).and_return [false, ['spec/javascripts/a.js.coffee']]
      end

      it 'throws :task_has_failed' do
        expect { guard.run_on_change(['spec/javascripts/a.js.coffee']) }.to throw_symbol :task_has_failed
      end

      it 'sets the last run failed to true' do
        expect { guard.run_on_change(['spec/javascripts/a.js.coffee']) }.to throw_symbol :task_has_failed
        guard.last_run_failed.should be_true
      end

      it 'appends the failed spec to the list of failed paths' do
        expect { guard.run_on_change(['spec/javascripts/a.js.coffee']) }.to throw_symbol :task_has_failed
        guard.last_failed_paths.should =~ ['spec/javascripts/a.js.coffee']
      end
    end

  end
end
