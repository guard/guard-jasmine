require 'guard/jasmine/cli'

RSpec.describe Guard::Jasmine::CLI do
  let(:cli) { ::Guard::Jasmine::CLI }
  let(:runner) { ::Guard::Jasmine::Runner }
  let(:server) { ::Guard::Jasmine::Server }

  before do
    allow(Process).to receive(:exit)
    new_method = runner.method(:new)
    allow(runner).to receive(:new) { |*args| new_method.call(*args) }
    allow_any_instance_of(runner).to receive(:run).and_return({})
    allow(server).to receive(:start)
    allow(server).to receive(:stop)
    allow(server).to receive(:detect_server)
    allow(cli).to receive(:which).and_return '/usr/local/bin/phantomjs'
    allow(cli).to receive(:phantomjs_bin_valid?).and_return true
    allow(cli).to receive(:runner_available?).and_return true

    allow(Guard::Compat::UI).to receive(:error)
  end

  describe '.spec' do
    context 'with specified options' do
      context 'with the server set to :none' do
        it 'does not start the server' do
          expect(server).not_to receive(:start)
          cli.start(['spec', '--server', 'none'])
        end
      end

      context 'without the server set to :none' do
        it 'starts the server' do
          expect(server).to receive(:start).with(hash_including(server: :thin))
          cli.start(['spec', '--server', 'thin'])
        end
      end

      context 'for the runner' do
        it 'passes the spec paths' do
          allow_any_instance_of(runner).to receive(:run)
            .with(['spec/javascripts/a_spec.js', 'spec/javascripts/another_spec.js'])
            .and_return {}
          cli.start(['spec', 'spec/javascripts/a_spec.js', 'spec/javascripts/another_spec.js'])
        end

        it 'sets the spec dir' do
          expect(runner).to receive(:new).with(hash_including(spec_dir: 'specs'))
          cli.start(['spec', '--spec-dir', 'specs'])
        end

        it 'sets the line number' do
          expect(runner).to receive(:new).with(hash_including(line_number: 1))
          cli.start(['spec', '--line-number', 1])
        end

        it 'detects the server type' do
          expect(server).to receive(:detect_server).with('specs')
          cli.start(['spec', '--spec-dir', 'specs'])
        end

        it 'enables focus mode' do
          expect(runner).to receive(:new).with(hash_including(focus: true))
          cli.start(['spec'])
        end

        it 'sets the jasmine url' do
          expect(runner).to receive(:new).with(hash_including(jasmine_url: 'http://smackaho.st:3000/jasmine'))
          cli.start(['spec', '--url', 'http://smackaho.st:3000/jasmine'])
        end

        it 'sets the jasmine mount point' do
          expect(runner).to receive(:new).with(hash_including(server_mount: '/foo'))
          cli.start(['spec', '--mount', '/foo'])
        end

        it 'sets the PhantomJS binary' do
          expect(runner).to receive(:new).with(hash_including(phantomjs_bin: '/bin/phantomjs'))
          cli.start(['spec', '--bin', '/bin/phantomjs'])
        end

        it 'sets the timeout' do
          expect(runner).to receive(:new).with(hash_including(timeout: 20_000))
          cli.start(['spec', '--timeout', '20000'])
        end

        it 'sets the verbose mode' do
          expect(runner).to receive(:new).with(hash_including(verbose: true))
          cli.start(['spec', '--verbose'])
        end

        it 'sets the server environment' do
          expect(runner).to receive(:new).with(hash_including(server_env: 'development'))
          cli.start(['spec', '--server-env', 'development'])
        end

        it 'sets the coverage support' do
          expect(runner).to receive(:new).with(hash_including(coverage: true))
          cli.start(['spec', '--coverage', 'true'])
        end

        it 'sets the coverage and coverage html support' do
          expect(runner).to receive(:new).with(hash_including(coverage: true, coverage_html: true))
          cli.start(['spec', '--coverage-html', 'true'])
        end

        it 'sets the coverage and coverage html directory' do
          expect(runner).to receive(:new).with(hash_including(coverage_html_dir: './coverage/js'))
          cli.start(['spec', '--coverage-html-dir', './coverage/js'])
        end

        it 'sets the coverage and coverage summary support' do
          expect(runner).to receive(:new).with(hash_including(coverage: true, coverage_summary: true))
          cli.start(['spec', '--coverage-summary', 'true'])
        end

        it 'sets the coverage statements threshold' do
          expect(runner).to receive(:new).with(hash_including(statements_threshold: 90))
          cli.start(['spec', '--statements-threshold', '90'])
        end

        it 'sets the coverage functions threshold' do
          expect(runner).to receive(:new).with(hash_including(functions_threshold: 80))
          cli.start(['spec', '--functions-threshold', '80'])
        end

        it 'sets the coverage branches threshold' do
          expect(runner).to receive(:new).with(hash_including(branches_threshold: 85))
          cli.start(['spec', '--branches-threshold', '85'])
        end

        it 'sets the coverage lines threshold' do
          expect(runner).to receive(:new).with(hash_including(lines_threshold: 95))
          cli.start(['spec', '--lines-threshold', '95'])
        end

        context 'for an invalid console option' do
          it 'sets the console option to failure' do
            expect(runner).to receive(:new).with(hash_including(console: :failure))
            cli.start(['spec', '--console', 'wrong'])
          end
        end

        context 'for a valid errors option' do
          it 'sets the errors option' do
            expect(runner).to receive(:new).with(hash_including(errors: :always))
            cli.start(['spec', '--errors', 'always'])
          end
        end

        context 'for an invalid errors option' do
          it 'sets the errors option to failure' do
            expect(runner).to receive(:new).with(hash_including(errors: :failure))
            cli.start(['spec', '--errors', 'wrong'])
          end
        end

        context 'for the reports option' do
          it 'sets the correct query parameters option' do
            expect(runner).to receive(:new).with(hash_including(query_params: { reporters: 'console' }))
            cli.start(['spec', '--reporters', 'console'])
          end
        end
      end
    end

    context 'without specified options' do
      context 'for the server' do
        it 'detects the server type' do
          expect(server).to receive(:detect_server).with('spec')
          cli.start(['spec'])
        end

        it 'sets the verbose mode' do
          expect(runner).to receive(:new).with(hash_including(verbose: false))
          cli.start(['spec'])
        end

        it 'sets the coverage support' do
          expect(runner).to receive(:new).with(hash_including(coverage: false))
          cli.start(['spec'])
        end

        it 'sets the coverage html support' do
          expect(runner).to receive(:new).with(hash_including(coverage_html: false))
          cli.start(['spec'])
        end

        it 'sets the coverage html directory' do
          expect(runner).to receive(:new).with(hash_including(coverage_html_dir: './coverage'))
          cli.start(['spec'])
        end

        it 'sets the coverage summary support' do
          expect(runner).to receive(:new).with(hash_including(coverage_summary: false))
          cli.start(['spec'])
        end

        it 'sets the coverage statements threshold' do
          expect(runner).to receive(:new).with(hash_including(statements_threshold: 0))
          cli.start(['spec'])
        end

        it 'sets the coverage functions threshold' do
          expect(runner).to receive(:new).with(hash_including(functions_threshold: 0))
          cli.start(['spec'])
        end

        it 'sets the coverage branches threshold' do
          expect(runner).to receive(:new).with(hash_including(branches_threshold: 0))
          cli.start(['spec'])
        end

        it 'sets the coverage lines threshold' do
          expect(runner).to receive(:new).with(hash_including(lines_threshold: 0))
          cli.start(['spec'])
        end
      end

      context 'for the runner' do
        context 'without a specific spec dir' do
          context 'with a spec/javascripts folder' do
            before do
              expect(File).to receive(:exist?).with('spec/javascripts').and_return true
            end

            it 'runs all specs in the spec/javascripts folder' do
              allow_any_instance_of(runner).to receive(:run).with(['spec/javascripts'])
              cli.start(['spec'])
            end
          end

          context 'without a spec/javascripts folder' do
            before do
              expect(File).to receive(:exist?).with('spec/javascripts').and_return false
            end

            it 'runs all specs in the spec folder' do
              allow_any_instance_of(runner).to receive(:run).with(['spec'])
              cli.start(['spec'])
            end
          end
        end

        context 'with a specific spec dir' do
          it 'runs all specs when the paths are empty' do
            allow_any_instance_of(runner).to receive(:run).with(['specs'])
            cli.start(['spec', '-d', 'specs'])
          end
        end

        context 'with JasmineRails module available' do
          before do
            stub_const 'JasmineRails', Module.new
          end

          it 'sets the server mount' do
            expect(runner).to receive(:new).with(hash_including(server_mount: '/specs'))
            cli.start(['spec'])
          end
        end

        context 'without JasmineRails module available' do
          it 'sets the server mount' do
            expect(runner).to receive(:new).with(hash_including(server_mount: '/jasmine'))
            cli.start(['spec'])
          end
        end

        it 'sets the spec dir' do
          expect(runner).to receive(:new).with(hash_including(spec_dir: 'spec'))
          cli.start(['spec'])
        end

        it 'sets the line number' do
          expect(runner).to receive(:new).with(hash_including(line_number: nil))
          cli.start(['spec'])
        end

        it 'disables the focus mode' do
          expect(runner).to receive(:new).with(hash_including(focus: false))
          cli.start(['spec', '-f', 'false'])
        end

        it 'auto detects the phantomjs binary' do
          expect(cli).to receive(:which).with('phantomjs').and_return '/tmp/phantomjs'
          expect(runner).to receive(:new).with(hash_including(phantomjs_bin: '/tmp/phantomjs'))
          cli.start(['spec'])
        end

        it 'sets the timeout' do
          expect(runner).to receive(:new).with(hash_including(timeout: 60))
          cli.start(['spec'])
        end

        it 'sets the console' do
          expect(runner).to receive(:new).with(hash_including(console: :failure))
          cli.start(['spec'])
        end

        it 'sets the server environment' do
          expect(runner).to receive(:new).with(hash_including(server_env: 'test'))
          cli.start(['spec'])
        end

        it 'sets the rackup config' do
          expect(runner).to receive(:new).with(hash_including(rackup_config: 'custom.ru'))
          cli.start(['spec', '--rackup-config', 'custom.ru'])
        end

        it 'sets the specdoc to always by default' do
          expect(runner).to receive(:new).with(hash_including(specdoc: :always))
          cli.start(['spec'])
        end

        it 'sets the specdoc to failure' do
          expect(runner).to receive(:new).with(hash_including(specdoc: :failure))
          cli.start(['spec', '--specdoc', 'failure'])
        end

        context 'with a defined port' do
          it 'uses the given port' do
            expect(runner).to receive(:new).with(hash_including(port: 3333))
            cli.start(['spec', '--port', '3333'])
          end

          it 'generates the default jasmine url with the given port' do
            expect(runner).to receive(:new).with(hash_including(jasmine_url: 'http://localhost:9876/jasmine'))
            cli.start(['spec', '--port', '9876'])
          end
        end

        context 'without a defined port' do
          it 'uses a free port' do
            expect(cli).to receive(:find_free_server_port).and_return 4321
            expect(runner).to receive(:new).with(hash_including(port: 4321))
            cli.start(['spec'])
          end

          it 'generates the default jasmine url with a free port' do
            expect(cli).to receive(:find_free_server_port).and_return 1234
            expect(runner).to receive(:new).with(hash_including(jasmine_url: 'http://localhost:1234/jasmine'))
            cli.start(['spec'])
          end
        end
      end

      context 'when using the jasmine gem' do
        it 'generates the default jasmine url' do
          expect(runner).to receive(:new).with(hash_including(jasmine_url: 'http://localhost:9876/'))
          cli.start(['spec', '--port', '9876', '--server', 'jasmine_gem'])
        end
      end

      context 'when using the jasminerice gem' do
        it 'generates the default jasmine url' do
          expect(runner).to receive(:new).with(hash_including(jasmine_url: 'http://localhost:9876/jasmine'))
          cli.start(['spec', '--port', '9876', '--server', 'thin'])
        end
      end
    end

    context 'for non changeable options' do
      it 'disables notifications' do
        expect(runner).to receive(:new).with(hash_including(notification: false))
        cli.start(['spec'])
      end

      it 'hides success notifications' do
        expect(runner).to receive(:new).with(hash_including(hide_success: true))
        cli.start(['spec'])
      end

      it 'sets the maximum error notifications to none' do
        expect(runner).to receive(:new).with(hash_including(max_error_notify: 0))
        cli.start(['spec'])
      end

      it 'sets :is_cli option to true' do
        expect(runner).to receive(:new).with(hash_including(is_cli: true))
        cli.start(['spec'])
      end
    end

    context 'without a valid phantomjs executable' do
      before do
        allow(cli).to receive(:phantomjs_bin_valid?).and_return false
      end

      it 'stops with an exit code 2' do
        expect(Process).to receive(:exit).with(2)
        cli.start(['spec'])
      end
    end

    context 'without the runner available' do
      before do
        allow(cli).to receive(:runner_available?).and_return false
      end

      it 'stops with an exit code 2' do
        expect(Process).to receive(:exit).with(2)
        cli.start(['spec'])
      end

      it 'attempts to stop the server process, that may be running' do
        expect(server).to receive(:stop)
        cli.start(['spec'])
      end
    end

    context 'with a runner exception' do
      it 'shows the error message' do
        expect(Guard::Compat::UI).to receive(:error).with('Something went wrong: BANG!')
        allow_any_instance_of(runner).to receive(:run).and_raise 'BANG!'
        cli.start(['spec'])
      end
    end

    context 'exit status' do
      it 'is 0 for a successful spec run' do
        expect(runner).to receive(:new).with(hash_including(spec_dir: 'specs'))
        expect(Process).to receive(:exit).with(0)
        cli.start(['spec', '--spec-dir', 'specs'])
      end

      it 'is 1 for a failed spec run' do
        expect(Process).to receive(:exit).with(1)
        allow_any_instance_of(runner).to receive(:run)
          .and_return('spec/javascript/a_failed_spec.js' => ['a bad error occured'])
        cli.start(['spec', '--spec-dir', 'specs'])
      end
    end
  end

  describe '.version' do
    it 'outputs the Guard::Jasmine version' do
      expect(Guard::Compat::UI).to receive(:info).with("Guard::Jasmine version #{::Guard::JasmineVersion::VERSION}")
      cli.start(['-v'])
    end
  end
end
