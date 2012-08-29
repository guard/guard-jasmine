require 'spec_helper'
require 'guard/jasmine/cli'

describe Guard::Jasmine::CLI do

  let(:cli) { ::Guard::Jasmine::CLI }
  let(:runner) { ::Guard::Jasmine::Runner }
  let(:server) { ::Guard::Jasmine::Server }

  before do
    Process.stub(:exit)
    runner.stub(:run)
    server.stub(:start)
    server.stub(:stop)
    cli.stub(:which).and_return '/usr/local/bin/phantomjs'
    cli.stub(:phantomjs_bin_valid?).and_return true
    cli.stub(:runner_available?).and_return true
  end

  describe '.spec' do
    context 'with specified options' do
      context 'for the server' do
        it 'sets the server type' do
          server.should_receive(:start).with(:thin, 3001, 'test', 'spec/javascripts')
          cli.start(['spec', '--server', 'thin'])
        end

        it 'sets the server port' do
          server.should_receive(:start).with(:auto, 4321, 'test', 'spec/javascripts')
          cli.start(['spec', '--port', '4321'])
        end

        it 'sets the spec dir' do
          server.should_receive(:start).with(:auto, 4321, 'test', 'specs')
          cli.start(['spec', '--port', '4321', '-d', 'specs'])
        end
      end

      context 'for the runner' do
        it 'passes the spec paths' do
          runner.should_receive(:run).with(['spec/javascripts/a_spec.js', 'spec/javascripts/another_spec.js'], anything()).and_return [true, []]
          cli.start(['spec', 'spec/javascripts/a_spec.js', 'spec/javascripts/another_spec.js'])
        end

        it 'sets the spec dir' do
          runner.should_receive(:run).with(anything(), hash_including(:spec_dir => 'specs')).and_return [true, []]
          cli.start(['spec', '--spec_dir', 'specs'])
        end

        it 'enables focus mode' do
          runner.should_receive(:run).with(anything(), hash_including(:focus => true)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the jasmine url' do
          runner.should_receive(:run).with(anything(), hash_including(:jasmine_url => 'http://smackaho.st:3000/jasmine')).and_return [true, []]
          cli.start(['spec', '--url', 'http://smackaho.st:3000/jasmine'])
        end

        it 'sets the PhantomJS binary' do
          runner.should_receive(:run).with(anything(), hash_including(:phantomjs_bin => '/bin/phantomjs')).and_return [true, []]
          cli.start(['spec', '--bin', '/bin/phantomjs'])
        end

        it 'sets the timeout' do
          runner.should_receive(:run).with(anything(), hash_including(:timeout => 20000)).and_return [true, []]
          cli.start(['spec', '--timeout', '20000'])
        end

        it 'sets the server environment' do
          runner.should_receive(:run).with(anything(), hash_including(:server_env => 'development')).and_return [true, []]
          cli.start(['spec', '--server_env', 'development'])
        end

        context 'for an invalid console option' do
          it 'sets the console option to failure' do
            runner.should_receive(:run).with(anything(), hash_including(:console => :failure)).and_return [true, []]
            cli.start(['spec', '--console', 'wrong'])
          end
        end

        context 'for a valid errors option' do
          it 'sets the errors option' do
            runner.should_receive(:run).with(anything(), hash_including(:errors => :always)).and_return [true, []]
            cli.start(['spec', '--errors', 'always'])
          end
        end

        context 'for an invalid errors option' do
          it 'sets the errors option to failure' do
            runner.should_receive(:run).with(anything(), hash_including(:errors => :failure)).and_return [true, []]
            cli.start(['spec', '--errors', 'wrong'])
          end
        end
      end
    end

    context 'without specified options' do
      context 'for the server' do
        it 'sets the server type' do
          server.should_receive(:start).with(:auto, 3001 , 'test', 'spec/javascripts')
          cli.start(['spec'])
        end
      end

      context 'for the runner' do
        context 'without a specific spec dir' do
          it 'runs all default specs when the paths are empty' do
            runner.should_receive(:run).with(['spec/javascripts'], anything()).and_return [true, []]
            cli.start(['spec'])
          end
        end

        context 'with a specific spec dir' do
          it 'runs all specs when the paths are empty' do
            runner.should_receive(:run).with(['specs'], anything()).and_return [true, []]
            cli.start(['spec', '-d', 'specs'])
          end
        end

        it 'sets the spec dir' do
          runner.should_receive(:run).with(anything(), hash_including(:spec_dir => 'spec/javascripts')).and_return [true, []]
          cli.start(['spec'])
        end

        it 'disables the focus mode' do
          runner.should_receive(:run).with(anything(), hash_including(:focus => false)).and_return [true, []]
          cli.start(['spec', '-f', 'false'])
        end

        it 'sets the default jasmine url' do
          runner.should_receive(:run).with(anything(), hash_including(:jasmine_url => 'http://localhost:3001/jasmine')).and_return [true, []]
          cli.start(['spec'])
        end

        it 'auto detects the phantomjs binary' do
          cli.should_receive(:which).with('phantomjs').and_return '/tmp/phantomjs'
          runner.should_receive(:run).with(anything(), hash_including(:phantomjs_bin => '/tmp/phantomjs')).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the timeout' do
          runner.should_receive(:run).with(anything(), hash_including(:timeout => 10000)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the console' do
          runner.should_receive(:run).with(anything(), hash_including(:console => :failure)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the server environment' do
          runner.should_receive(:run).with(anything(), hash_including(:server_env => 'test')).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the specdoc to always by default' do
          runner.should_receive(:run).with(anything(), hash_including(:specdoc => :always)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the specdoc to failure' do
          runner.should_receive(:run).with(anything(), hash_including(:specdoc => :failure)).and_return [true, []]
          cli.start(['spec', '--specdoc', 'failure'])
        end

      end
    end

    context 'for non changeable options' do
      it 'disables notifications' do
        runner.should_receive(:run).with(anything(), hash_including(:notification => false)).and_return [true, []]
        cli.start(['spec'])
      end

      it 'hides success notifications' do
        runner.should_receive(:run).with(anything(), hash_including(:hide_success => true)).and_return [true, []]
        cli.start(['spec'])
      end

      it 'sets the maximum error notifications to none' do
        runner.should_receive(:run).with(anything(), hash_including(:max_error_notify => 0)).and_return [true, []]
        cli.start(['spec'])
      end
    end

    context 'without a valid phantomjs executable' do
      before do
        cli.stub(:phantomjs_bin_valid?).and_return false
      end

      it 'stops with an exit code 2' do
        Process.should_receive(:exit).with(2)
        cli.start(['spec'])
      end
    end

    context 'without the runner available' do
      before do
        cli.stub(:runner_available?).and_return false
      end

      it 'stops with an exit code 2' do
        Process.should_receive(:exit).with(2)
        cli.start(['spec'])
      end

      it 'attemps to stop the server process, that may be running' do
        server.should_receive(:stop)
        cli.start(['spec'])
      end
    end

    context 'with a runner exception' do
      it 'shows the error message' do
        ::Guard::UI.should_receive(:error).with('Something went wrong')
        runner.should_receive(:run).and_raise 'Something went wrong'
        cli.start(['spec'])
      end
    end

    context 'exit status' do
      it 'is 0 for a successful spec run' do
        Process.should_receive(:exit).with(0)
        runner.should_receive(:run).and_return [true, []]
        cli.start(['spec'])
      end

      it 'is 1 for a failed spec run' do
        Process.should_receive(:exit).with(1)
        runner.should_receive(:run).and_return [false, ['spec/javascript/a_failed_spec.js']]
        cli.start(['spec'])
      end
    end
  end

  describe '.version' do
    it 'outputs the Guard::Jasmine version' do
      ::Guard::UI.should_receive(:info).with("Guard::Jasmine version #{ ::Guard::JasmineVersion::VERSION }")
      cli.start(['-v'])
    end
  end

end
