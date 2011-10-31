require 'spec_helper'
require 'guard/jasmine/cli'

describe Guard::Jasmine::CLI do

  let(:cli) { ::Guard::Jasmine::CLI }
  let(:runner) { ::Guard::Jasmine::Runner }

  describe '.spec' do
    context 'with specified options' do
      it 'passes the paths to the runner' do
        runner.should_receive(:run).with(['spec/javascripts/a_spec.js', 'spec/javascripts/another_spec.js'], anything()).and_return [true, []]
        expect { cli.start(['spec', 'spec/javascripts/a_spec.js', 'spec/javascripts/another_spec.js']) }.to raise_exception SystemExit
      end

      it 'sets the jasmine url for the runner' do
        runner.should_receive(:run).with(anything(), hash_including(:jasmine_url => 'http://smackaho.st:3000/jasmine')).and_return [true, []]
        expect { cli.start(['spec', '--url', 'http://smackaho.st:3000/jasmine']) }.to raise_exception SystemExit
      end

      it 'sets the PhantomJS binary for the runner' do
        runner.should_receive(:run).with(anything(), hash_including(:phantomjs_bin => '/bin/phantomjs')).and_return [true, []]
        expect { cli.start(['spec', '--bin', '/bin/phantomjs']) }.to raise_exception SystemExit
      end

      it 'sets the timeout for the runner' do
        runner.should_receive(:run).with(anything(), hash_including(:timeout => 20000)).and_return [true, []]
        expect { cli.start(['spec', '--timeout', '20000']) }.to raise_exception SystemExit
      end

      context 'for a valid console option' do
        it 'sets the console.log for the runner' do
          runner.should_receive(:run).with(anything(), hash_including(:console => :always)).and_return [true, []]
          expect { cli.start(['spec', '-c', 'always']) }.to raise_exception SystemExit
        end
      end

      context 'for an invalid console option' do
        it 'sets the console option to failure' do
          runner.should_receive(:run).with(anything(), hash_including(:console => :failure)).and_return [true, []]
          expect { cli.start(['spec', '-c', 'wrong']) }.to raise_exception SystemExit
        end
      end
    end

    context 'without specified options' do
      it 'runs all specs when the paths are empty' do
        runner.should_receive(:run).with(['spec/javascripts'], anything()).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end

      it 'sets the default jasmine url for the runner' do
        runner.should_receive(:run).with(anything(), hash_including(:jasmine_url => 'http://127.0.0.1:3000/jasmine')).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end

      it 'sets the default PhantomJS binary for the runner' do
        runner.should_receive(:run).with(anything(), hash_including(:phantomjs_bin => '/usr/local/bin/phantomjs')).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end

      it 'sets the timeout for the runner' do
        runner.should_receive(:run).with(anything(), hash_including(:timeout => 10000)).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end

      it 'sets the console for the runner' do
        runner.should_receive(:run).with(anything(), hash_including(:console => :failure)).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end
    end

    context 'for non changeable options' do
      it 'disables notifications' do
        runner.should_receive(:run).with(anything(), hash_including(:notification => false)).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end

      it 'hides success notifications' do
        runner.should_receive(:run).with(anything(), hash_including(:hide_success => true)).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end

      it 'sets the maximum error notifications to none' do
        runner.should_receive(:run).with(anything(), hash_including(:max_error_notify => 0)).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end

      it 'sets the specdoc to always' do
        runner.should_receive(:run).with(anything(), hash_including(:specdoc => :always)).and_return [true, []]
        expect { cli.start(['spec']) }.to raise_exception SystemExit
      end
    end

    context 'with a runner exception' do
      it 'shows the error message' do
        ::Guard::UI.should_receive(:error).with('Something went wrong')
        runner.should_receive(:run).and_raise 'Something went wrong'
        expect { cli.start(['spec']) }.to raise_exception SystemExit
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
      ::Guard::UI.should_receive(:info).with("Guard::Jasmine version #{ ::Guard::JasmineVersion }")
      cli.start(['-v'])
    end
  end

end
