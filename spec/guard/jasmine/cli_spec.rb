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
      context 'with the server set to :none' do
        it 'does not start the server' do
          server.should_not_receive(:start)
          cli.start(['spec', '--server', 'none'])
        end
      end

      context 'without the server set to :none' do
        it 'starts the server' do
          server.should_receive(:start).with(hash_including(:server => :thin))
          cli.start(['spec', '--server', 'thin'])
        end
      end

      context 'for the runner' do
        it 'passes the spec paths' do
          runner.should_receive(:run).with(['spec/javascripts/a_spec.js', 'spec/javascripts/another_spec.js'], anything()).and_return [true, []]
          cli.start(['spec', 'spec/javascripts/a_spec.js', 'spec/javascripts/another_spec.js'])
        end

        it 'sets the spec dir' do
          runner.should_receive(:run).with(anything(), hash_including(:spec_dir => 'specs')).and_return [true, []]
          cli.start(['spec', '--spec-dir', 'specs'])
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
          cli.start(['spec', '--server-env', 'development'])
        end

        it 'sets the coverage support' do
          runner.should_receive(:run).with(anything(), hash_including(:coverage => true)).and_return [true, []]
          cli.start(['spec', '--coverage', 'true'])
        end

        it 'sets the coverage and coverage html support' do
          runner.should_receive(:run).with(anything(), hash_including(:coverage => true, :coverage_html => true)).and_return [true, []]
          cli.start(['spec', '--coverage-html', 'true'])
        end

        it 'sets the coverage and coverage summary support' do
          runner.should_receive(:run).with(anything(), hash_including(:coverage => true, :coverage_summary => true)).and_return [true, []]
          cli.start(['spec', '--coverage-summary', 'true'])
        end

        it 'sets the coverage statements threshold' do
          runner.should_receive(:run).with(anything(), hash_including(:statements_threshold => 90)).and_return [true, []]
          cli.start(['spec', '--statements-threshold', '90'])
        end

        it 'sets the coverage functions threshold' do
          runner.should_receive(:run).with(anything(), hash_including(:functions_threshold => 80)).and_return [true, []]
          cli.start(['spec', '--functions-threshold', '80'])
        end

        it 'sets the coverage branches threshold' do
          runner.should_receive(:run).with(anything(), hash_including(:branches_threshold => 85)).and_return [true, []]
          cli.start(['spec', '--branches-threshold', '85'])
        end

        it 'sets the coverage lines threshold' do
          runner.should_receive(:run).with(anything(), hash_including(:lines_threshold => 95)).and_return [true, []]
          cli.start(['spec', '--lines-threshold', '95'])
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
          server.should_receive(:start).with(hash_including(:server => :auto))
          cli.start(['spec'])
        end

        it 'sets the coverage support' do
          runner.should_receive(:run).with(anything(), hash_including(:coverage => false)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the coverage html support' do
          runner.should_receive(:run).with(anything(), hash_including(:coverage_html => false)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the coverage summary support' do
          runner.should_receive(:run).with(anything(), hash_including(:coverage_summary => false)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the coverage statements threshold' do
          runner.should_receive(:run).with(anything(), hash_including(:statements_threshold => 0)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the coverage functions threshold' do
          runner.should_receive(:run).with(anything(), hash_including(:functions_threshold => 0)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the coverage branches threshold' do
          runner.should_receive(:run).with(anything(), hash_including(:branches_threshold => 0)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the coverage lines threshold' do
          runner.should_receive(:run).with(anything(), hash_including(:lines_threshold => 0)).and_return [true, []]
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

        it 'auto detects the phantomjs binary' do
          cli.should_receive(:which).with('phantomjs').and_return '/tmp/phantomjs'
          runner.should_receive(:run).with(anything(), hash_including(:phantomjs_bin => '/tmp/phantomjs')).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the timeout' do
          runner.should_receive(:run).with(anything(), hash_including(:timeout => 60)).and_return [true, []]
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

        it 'sets the rackup config' do
          runner.should_receive(:run).with(anything(), hash_including(:rackup_config => 'custom.ru')).and_return [true, []]
          cli.start(['spec', '--rackup-config', 'custom.ru'])
        end

        it 'sets the specdoc to always by default' do
          runner.should_receive(:run).with(anything(), hash_including(:specdoc => :always)).and_return [true, []]
          cli.start(['spec'])
        end

        it 'sets the specdoc to failure' do
          runner.should_receive(:run).with(anything(), hash_including(:specdoc => :failure)).and_return [true, []]
          cli.start(['spec', '--specdoc', 'failure'])
        end

        context 'with a defined port' do
          it 'uses the given port' do
            runner.should_receive(:run).with(anything(), hash_including(:port => 3333)).and_return [true, []]
            cli.start(['spec', '--port', '3333'])
          end

          it 'generates the default jasmine url with the given port' do
            runner.should_receive(:run).with(anything(), hash_including(:jasmine_url => 'http://localhost:9876/jasmine')).and_return [true, []]
            cli.start(['spec', '--port', '9876'])
          end
        end

        context 'without a defined port' do
          it 'uses a free port' do
            cli.should_receive(:find_free_server_port).and_return 4321
            runner.should_receive(:run).with(anything(), hash_including(:port => 4321)).and_return [true, []]
            cli.start(['spec'])
          end

          it 'generates the default jasmine url with a free port' do
            cli.should_receive(:find_free_server_port).and_return 1234
            runner.should_receive(:run).with(anything(), hash_including(:jasmine_url => 'http://localhost:1234/jasmine')).and_return [true, []]
            cli.start(['spec'])
          end
        end
      end

      context 'when using the jasmine gem' do
        it 'generates the default jasmine url' do
          runner.should_receive(:run).with(anything(), hash_including(:jasmine_url => 'http://localhost:9876/')).and_return [true, []]
          cli.start(['spec', '--port', '9876', '--server', 'jasmine_gem'])
        end
      end

      context 'when using the jasminerice gem' do
        it 'generates the default jasmine url' do
          runner.should_receive(:run).with(anything(), hash_including(:jasmine_url => 'http://localhost:9876/jasmine')).and_return [true, []]
          cli.start(['spec', '--port', '9876', '--server', 'thin'])
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

      it 'attempts to stop the server process, that may be running' do
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
