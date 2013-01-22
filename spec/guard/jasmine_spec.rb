require 'spec_helper'

describe Guard::Jasmine do

  let(:guard) { Guard::Jasmine.new }

  let(:runner) { Guard::Jasmine::Runner }
  let(:inspector) { Guard::Jasmine::Inspector }
  let(:formatter) { Guard::Jasmine::Formatter }
  let(:server) { Guard::Jasmine::Server }

  let(:defaults) { Guard::Jasmine::DEFAULT_OPTIONS }

  before do
    inspector.stub(:clean).and_return { |specs, options| specs }
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
        guard.options[:server_env].should eql defaults[:server_env]
      end

      it 'sets a default :server_timeout option' do
        guard.options[:server_timeout].should eql 15
      end

      it 'finds a free port for the :port option' do
        Guard::Jasmine.should_receive(:find_free_server_port).and_return 9999
        guard = Guard::Jasmine.new
        guard.options[:port].should eql 9999
      end

      it 'sets a default :rackup_config option' do
        guard.options[:rackup_config].should eql nil
      end

      it 'sets a default :timeout option' do
        guard.options[:timeout].should eql 10
      end

      it 'sets a default :spec_dir option' do
        guard.options[:spec_dir].should eql 'spec/javascripts'
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

      it 'sets a default :errors option' do
        guard.options[:errors].should eql :failure
      end

      it 'sets a default :focus option' do
        guard.options[:focus].should eql true
      end

      it 'sets a default :clean option' do
        guard.options[:clean].should eql true
      end

      it 'sets a default :coverage option' do
        guard.options[:coverage].should eql false
      end

      it 'sets a default :coverage_html option' do
        guard.options[:coverage_html].should eql false
      end

      it 'sets a default :coverage_summary option' do
        guard.options[:coverage_summary].should eql false
      end

      it 'sets a :statements_threshold option' do
        guard.options[:statements_threshold].should eql 0
      end

      it 'sets a :functions_threshold option' do
        guard.options[:functions_threshold].should eql 0
      end

      it 'sets a :branches_threshold option' do
        guard.options[:branches_threshold].should eql 0
      end

      it 'sets a :lines_threshold option' do
        guard.options[:lines_threshold].should eql 0
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
      let(:guard) { Guard::Jasmine.new(nil, {
        :server               => :jasmine_gem,
        :server_env           => 'test',
        :server_timeout       => 20,
        :port                 => 4321,
        :rackup_config        => 'spec/dummy/config.ru',
        :jasmine_url          => 'http://192.168.1.5/jasmine',
        :phantomjs_bin        => '~/bin/phantomjs',
        :timeout              => 20000,
        :spec_dir             => 'spec',
        :all_on_start         => false,
        :notification         => false,
        :max_error_notify     => 5,
        :hide_success         => true,
        :keep_failed          => false,
        :all_after_pass       => false,
        :specdoc              => :always,
        :focus                => false,
        :clean                => false,
        :errors               => :always,
        :console              => :always,
        :coverage             => true,
        :coverage_html        => true,
        :coverage_summary     => true,
        :statements_threshold => 95,
        :functions_threshold  => 90,
        :branches_threshold   => 85,
        :lines_threshold      => 80
      }) }

      it 'sets the :server option' do
        guard.options[:server].should eql :jasmine_gem
      end

      it 'sets the :server_env option' do
        guard.options[:server_env].should eql 'test'
      end

      it 'sets the :server_timeout option' do
        guard.options[:server_timeout].should eql 20
      end

      it 'sets the :port option' do
        guard.options[:port].should eql 4321
      end

      it 'sets a default :rackup_config option' do
        guard.options[:rackup_config].should eql 'spec/dummy/config.ru'
      end

      it 'sets the :phantomjs_bin option' do
        guard.options[:phantomjs_bin].should eql '~/bin/phantomjs'
      end

      it 'sets the :phantomjs_bin option' do
        guard.options[:timeout].should eql 20000
      end

      it 'sets the :spec_dir option' do
        guard.options[:spec_dir].should eql 'spec'
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

      it 'sets the :errors option' do
        guard.options[:errors].should eql :always
      end

      it 'sets the :focus option' do
        guard.options[:focus].should eql false
      end

      it 'sets the :clean option' do
        guard.options[:clean].should eql false
      end

      it 'sets a :coverage option' do
        guard.options[:coverage].should eql true
      end

      it 'sets a default :coverage_html option' do
        guard.options[:coverage_html].should eql true
      end

      it 'sets a default :coverage_summary option' do
        guard.options[:coverage_summary].should eql true
      end

      it 'sets a :statements_threshold option' do
        guard.options[:statements_threshold].should eql 95
      end

      it 'sets a :functions_threshold option' do
        guard.options[:functions_threshold].should eql 90
      end

      it 'sets a :branches_threshold option' do
        guard.options[:branches_threshold].should eql 85
      end

      it 'sets a :lines_threshold option' do
        guard.options[:lines_threshold].should eql 80
      end
    end

    context 'with run all options' do
      let(:guard) { Guard::Jasmine.new(nil, { :run_all => { :test => true } }) }

      it 'removes them from the default options' do
        guard.options[:run_all].should be_nil
      end

      it 'saves the run_all options' do
        guard.run_all_options.should eql({ :test => true })
      end

    end

    context 'with a port but no jasmine_url option set' do
      let(:guard) { Guard::Jasmine.new(nil, { :port => 4321 }) }

      it 'sets the port on the jasmine_url' do
        guard.options[:jasmine_url].should eql 'http://localhost:4321/jasmine'
      end
    end

    context 'without a port but no jasmine_url option set' do
      it 'sets detected free server port on the jasmine_url' do
        Guard::Jasmine.should_receive(:find_free_server_port).and_return 7654
        guard = Guard::Jasmine.new
        guard.options[:jasmine_url].should eql 'http://localhost:7654/jasmine'
      end
    end

    context 'with illegal options' do
      let(:guard) { Guard::Jasmine.new(nil, defaults.merge({ :specdoc => :wrong, :server => :unknown })) }

      it 'sets default :specdoc option' do
        guard.options[:specdoc].should eql :failure
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
          server.should_receive(:start).with(hash_including(:server        => :jasmine_gem,
                                                            :port          => 3333,
                                                            :server_env    => 'test',
                                                            :spec_dir      => 'spec/javascripts',
                                                            :rackup_config => nil))
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
    let(:options) { defaults.merge({ :phantomjs_bin => '/bin/phantomjs' }) }
    let(:guard) { Guard::Jasmine.new(nil, options) }

    context 'without a specified spec dir' do
      it 'starts the Runner with the default spec dir' do
        runner.should_receive(:run).with(['spec/javascripts'], options).and_return [['spec/javascripts/a.js.coffee'], true]

        guard.run_all
      end
    end

    context 'with a specified spec dir' do
      let(:options) { defaults.merge({ :phantomjs_bin => '/bin/phantomjs', :spec_dir => 'specs' }) }
      let(:guard) { Guard::Jasmine.new(nil, options) }

      it 'starts the Runner with the default spec dir' do
        runner.should_receive(:run).with(['specs'], options).and_return [['spec/javascripts/a.js.coffee'], true]

        guard.run_all
      end
    end

    context 'with run all options' do
      let(:guard) { Guard::Jasmine.new(nil, { :run_all => { :specdoc => :overwritten } }) }

      it 'starts the Runner with the merged run all options' do
        runner.should_receive(:run).with(['spec/javascripts'], hash_including({ :specdoc => :overwritten })).and_return [['spec/javascripts/a.js.coffee'], true]

        guard.run_all
      end
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

  describe '.run_on_changes' do
    let(:options) { defaults.merge({ :phantomjs_bin => '/Users/michi/.bin/phantomjs' }) }
    let(:guard) { Guard::Jasmine.new(nil, options) }

    it 'returns false when no valid paths are passed' do
      inspector.should_receive(:clean).and_return []
      guard.run_on_changes(['spec/javascripts/b.js.coffee'])
    end

    it 'starts the Runner with the cleaned files' do
      inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                             'spec/javascripts/b.js.coffee'], options).and_return ['spec/javascripts/a.js.coffee']

      runner.should_receive(:run).with(['spec/javascripts/a.js.coffee'], options).and_return [['spec/javascripts/a.js.coffee'], true]

      guard.run_on_changes(['spec/javascripts/a.js.coffee', 'spec/javascripts/b.js.coffee'])
    end

    context 'with :clean enabled' do
      let(:options) { defaults.merge({ :clean => true, :phantomjs_bin => '/usr/bin/phantomjs' }) }
      let(:guard) { Guard::Jasmine.new(nil, options) }

      it 'passes the paths to the Inspector for cleanup' do
        inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                               'spec/javascripts/b.js.coffee'], options)

        guard.run_on_changes(['spec/javascripts/a.js.coffee',
                              'spec/javascripts/b.js.coffee'])
      end
    end

    context 'with :clean disabled' do
      let(:options) { defaults.merge({ :clean => false, :phantomjs_bin => '/usr/bin/phantomjs' }) }
      let(:guard) { Guard::Jasmine.new(nil, options) }

      it 'does not pass the paths to the Inspector for cleanup' do
        inspector.should_not_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                                   'spec/javascripts/b.js.coffee'], options)

        guard.run_on_changes(['spec/javascripts/a.js.coffee',
                              'spec/javascripts/b.js.coffee'])
      end
    end

    context 'with :keep_failed enabled' do
      let(:options) { defaults.merge({ :keep_failed => true, :phantomjs_bin => '/usr/bin/phantomjs' }) }
      let(:guard) { Guard::Jasmine.new(nil, options) }

      before do
        guard.last_failed_paths = ['spec/javascripts/b.js.coffee']
      end

      it 'passes the paths to the Inspector for cleanup' do
        inspector.should_receive(:clean).with(['spec/javascripts/a.js.coffee',
                                               'spec/javascripts/b.js.coffee'], options)

        guard.run_on_changes(['spec/javascripts/a.js.coffee'])
      end

      it 'appends the last failed paths to the current run' do
        runner.should_receive(:run).with(['spec/javascripts/a.js.coffee',
                                          'spec/javascripts/b.js.coffee'], options)

        guard.run_on_changes(['spec/javascripts/a.js.coffee'])
      end
    end

    context 'with only success specs' do
      before do
        guard.last_failed_paths = ['spec/javascripts/a.js.coffee']
        guard.last_run_failed   = true
        runner.stub(:run).and_return [true, []]
      end

      it 'sets the last run failed to false' do
        guard.run_on_changes(['spec/javascripts/a.js.coffee'])
        guard.last_run_failed.should be_false
      end

      it 'removes the passed specs from the list of failed paths' do
        guard.run_on_changes(['spec/javascripts/a.js.coffee'])
        guard.last_failed_paths.should be_empty
      end

      context 'when :all_after_pass is enabled' do
        let(:guard) { Guard::Jasmine.new(nil, { :all_after_pass => true }) }

        it 'runs all specs' do
          guard.should_receive(:run_all)
          guard.run_on_changes(['spec/javascripts/a.js.coffee'])
        end
      end

      context 'when :all_after_pass is enabled' do
        let(:guard) { Guard::Jasmine.new(nil, { :all_after_pass => false }) }

        it 'does not run all specs' do
          guard.should_not_receive(:run_all)
          guard.run_on_changes(['spec/javascripts/a.js.coffee'])
        end
      end
    end

    context 'with failing specs' do
      before do
        guard.last_run_failed = false
        runner.stub(:run).and_return [false, ['spec/javascripts/a.js.coffee']]
      end

      it 'throws :task_has_failed' do
        expect { guard.run_on_changes(['spec/javascripts/a.js.coffee']) }.to throw_symbol :task_has_failed
      end

      it 'sets the last run failed to true' do
        expect { guard.run_on_changes(['spec/javascripts/a.js.coffee']) }.to throw_symbol :task_has_failed
        guard.last_run_failed.should be_true
      end

      it 'appends the failed spec to the list of failed paths' do
        expect { guard.run_on_changes(['spec/javascripts/a.js.coffee']) }.to throw_symbol :task_has_failed
        guard.last_failed_paths.should =~ ['spec/javascripts/a.js.coffee']
      end
    end

  end
end
