# coding: utf-8

require 'spec_helper'
require 'pathname'
def read_fixture(name)
  Pathname.new(__FILE__).dirname.join('fixtures',name+'.json').read
end

describe Guard::Jasmine::Runner do

  let(:formatter) { Guard::Jasmine::Formatter }

  let(:defaults) { Guard::Jasmine::DEFAULT_OPTIONS.merge({
    jasmine_url:   'http://localhost:8888/jasmine',
    phantomjs_bin: '/usr/local/bin/phantomjs',
    spec_dir:      'spec/javascripts'  })
  }
  let(:runner) { Guard::Jasmine::Runner.new(defaults) }

  let(:phantomjs_empty_response) do
    ''
  end

  let(:phantomjs_invalid_response) do
    <<-JSON
      { 1 }
    JSON
  end

  let(:phantomjs_failure_response){  read_fixture('failure') }
  let(:phantomjs_success_response){  read_fixture('success') }
  let(:phantomjs_coverage_response){ read_fixture('coverage') }
  let(:phantomjs_error_response){ '{ "error": "Cannot request Jasmine specs" }' }
  let(:phantomjs_command){ "/usr/local/bin/phantomjs #@project_path/lib/guard/jasmine/phantomjs/guard-jasmine.js" }

  before do
    allow(formatter).to receive(:info)
    allow(formatter).to receive(:debug)
    allow(formatter).to receive(:error)
    allow(formatter).to receive(:sucess)
    allow(formatter).to receive(:spec_failed)
    allow(formatter).to receive(:suite_name)
    allow(formatter).to receive(:notify)

    allow(runner).to receive(:`) #`
    allow(runner).to receive(:update_coverage)
  end

  describe '#run' do
    before do
      allow(File).to receive(:foreach).and_yield 'describe "ErrorTest", ->'
      allow(File).to receive(:exist?).and_return(true)
      allow(IO).to   receive(:popen).and_return StringIO.new(phantomjs_error_response)
    end

    context 'when passed an empty paths list' do
      it 'returns false' do
        expect( runner.run([]) ).to be_empty
      end
    end

    context 'when the spec file does not exist' do
      it 'does nothing' do
        allow(File).to receive(:exist?).with('spec/javascripts').and_return(false)
        expect(runner).not_to receive(:evaluate_response)
        runner.run(['spec/javascripts'])
      end
    end

    context 'when passed a line number' do
      before do
        allow(File).to receive(:readlines).and_return([
          'describe "TestContext", ->',                # 1
          '  describe "Inner TestContext", ->',        # 2
          '    describe "Unrelated TestContext", ->',  # 3
          '      it "does something", ->',             # 4
          '        # some code',                       # 5
          '        # some assertion',                  # 6
          '    it "does something else", ->',          # 7
          '      # some assertion',                    # 8
          '  it "does something a lot else", ->',      # 9
          '    # some assertion'                       # 10
        ])
      end
      context "with custom parameters" do
        it 'sets the url query parmeters' do
          expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?debug=true&myval=1&spec=ErrorTest\" 60000 failure true failure failure false true ''", "r:UTF-8")
          runner.run(['spec/javascripts/a.js.coffee'], query_params: {debug:true, myval:1})
        end
      end
      context 'with the spec file name' do
        it 'executes the example for line number on example' do
          expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=TestContext%20Inner%20TestContext%20does%20something%20else\" 60000 failure true failure failure false true ''", "r:UTF-8")
          runner.run(['spec/javascripts/a.js.coffee:7'])
        end

        it 'executes the example for line number within example' do
          expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=TestContext%20Inner%20TestContext%20does%20something%20else\" 60000 failure true failure failure false true ''", "r:UTF-8")
          runner.run(['spec/javascripts/a.js.coffee:8'])
        end

        it 'executes all examples within describe' do
          expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=TestContext\" 60000 failure true failure failure false true ''", "r:UTF-8")
          runner.run(['spec/javascripts/a.js.coffee:1'])
        end
      end

      context 'with the cli argument' do
        it 'executes the example for line number on example' do
          expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=TestContext%20Inner%20TestContext%20does%20something%20else\" 60000 failure true failure failure false true ''", "r:UTF-8")
          runner.run(['spec/javascripts/a.js.coffee'],{ line_number: 7 })
        end
        it 'also sets custom parameters' do
          expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?debug=true&spec=TestContext%20Inner%20TestContext%20does%20something%20else\" 60000 failure true failure failure false true ''", "r:UTF-8")
          runner.run(['spec/javascripts/a.js.coffee'],{ line_number: 7, query_params:{debug: true} })
        end
      end

    end

    context 'when passed the spec directory' do
      it 'requests all jasmine specs from the server' do
        expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine\" 60000 failure true failure failure false true ''", "r:UTF-8")
        runner.run(['spec/javascripts'],{ notification: false })
      end

      it 'shows a start information in the console' do
        expect(formatter).to receive(:info).with('Run all Jasmine suites', { reset: true })
        runner.run(['spec/javascripts'])
      end
    end

    context 'when passing junit options' do
      it 'passes the junit option to the runner' do
        expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine\" 60000 failure true failure failure true true ''", "r:UTF-8")
        runner.run(['spec/javascripts'], { junit: true })
      end

      it 'passes the junit consolidate option' do
        expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine\" 60000 failure true failure failure false false ''", "r:UTF-8")
        runner.run(['spec/javascripts'], { junit_consolidate: false })
      end

      it 'passes the junit save path' do
        expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine\" 60000 failure true failure failure false true '/home/user'", "r:UTF-8")
        runner.run(['spec/javascripts'], { junit_save_path: '/home/user' })
      end
    end

    context 'for an erroneous Jasmine runner' do
      it 'requests the jasmine specs from the server' do
        expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=ErrorTest\" 60000 failure true failure failure false true ''", "r:UTF-8")
        runner.run(['spec/javascripts/a.js.coffee'])
      end

      it 'shows the error in the console' do
        expect(formatter).to receive(:error).with(
          'An error occurred: Cannot request Jasmine specs'
        )
        runner.run(['spec/javascripts/a.js.coffee'])
      end

      it 'returns the errors' do
        response = runner.run(['spec/javascripts/a.js.coffee'])
        expect(response).to have_key('spec/javascripts/a.js.coffee')
      end

      it 'does not show coverage' do
        expect(runner).not_to receive(:notify_coverage_result)
        runner.run(['spec/javascripts/a.js.coffee'])
      end

      context 'with notifications' do
        it 'shows an error notification' do
          expect(formatter).to receive(:notify).with(
            'An error occurred: Cannot request Jasmine specs',
            title:    'Jasmine error',
            image:    :failed,
            priority: 2
          )
          runner.run(['spec/javascripts/a.js.coffee'])
        end
      end

      context 'without notifications' do
        it 'does not shows an error notification' do
          expect(formatter).not_to receive(:notify)
          runner.run(['spec/javascripts/a.js.coffee'], notification: false)
        end
      end
    end

    context 'exceptions for the CLI runner' do
      before do
        allow(File).to receive(:foreach).and_yield 'describe "FailureTest", ->'
      end

      it 'raises an error with an empty JSON response' do
        allow(IO).to receive(:popen).and_return StringIO.new(phantomjs_empty_response)

        expect do
          runner.run(['spec/javascripts/x/b.js.coffee'], is_cli: true)
        end.to raise_error "No response from Jasmine runner"
      end

      it 'raises an error with an invalid JSON response' do
        allow(IO).to receive(:popen).and_return StringIO.new(phantomjs_invalid_response)

        expect do
          runner.run(['spec/javascripts/x/b.js.coffee'], is_cli: true)
        end.to raise_error "Cannot decode JSON from PhantomJS runner, message received was:\n#{phantomjs_invalid_response}"
      end

      it 'raises an error with an error JSON response' do
        allow(IO).to receive(:popen).and_return StringIO.new(phantomjs_error_response)

        expect do
          runner.run(['spec/javascripts/x/b.js.coffee'], is_cli: true)
        end.to raise_error 'An error occurred in the Jasmine runner'
      end
    end

    context 'for a failing Jasmine runner' do
      before do
        allow(File).to receive(:foreach).and_yield 'describe "FailureTest", ->'
        allow(IO).to receive(:popen).and_return StringIO.new(phantomjs_failure_response)
      end

      it 'requests the jasmine specs from the server' do
        expect(File).to receive(:foreach).with('spec/javascripts/x/b.js.coffee').and_yield 'describe "FailureTest", ->'
        expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=FailureTest\" 60000 failure true failure failure false true ''", "r:UTF-8")
        runner.run(['spec/javascripts/x/b.js.coffee'])
      end

      it 'returns the failures' do
        response = runner.run(['spec/javascripts/x/b.js.coffee'])
        expect(response).to have_key('spec/javascripts/x/b.js.coffee' )
      end

      it 'does not show coverage' do
        expect(runner).not_to receive(:notify_coverage_result)
        runner.run(['spec/javascripts/a.js.coffee'])
      end

      context 'with the specdoc set to :always' do
        it 'shows the pendign specs' do
          expect(formatter).to receive(:spec_pending).with(
            '  ○ Horribly Broken Spec'
          )
          runner.run(['spec/javascripts/x/b.js.coffee'], { specdoc: :always, console: :never, errors: :never })
        end
      end

      context 'with the specdoc set to :never' do
          context 'and console and errors set to :never' do
              it 'shows the summary in the console' do
                  expect(formatter).to receive(:info).with(
                      'Run Jasmine suite spec/javascripts/x/b.js.coffee', { reset: true }
                  )
                  expect(formatter).not_to receive(:suite_name)
                  expect(formatter).not_to receive(:spec_failed)
                  expect(formatter).to receive(:error).with('4 specs, 1 pending, 2 failures')
                  runner.run(['spec/javascripts/x/b.js.coffee'], { specdoc: :never, console: :never, errors: :never })
              end

              it 'hides the pending specs' do
                expect(formatter).to_not receive(:spec_pending).with(
                  '  ○ Horribly Broken Spec'
                )
                runner.run(['spec/javascripts/x/b.js.coffee'], { specdoc: :never, console: :never, errors: :never })
              end
          end

          context 'and console set to :failure' do
              it 'hides all messages' do
                  expect(formatter).not_to receive(:suite_name)
                  expect(formatter).not_to receive(:spec_failed)
                  expect(formatter).not_to receive(:spec_failed)
                  expect(formatter).not_to receive(:suite_name)
                  expect(formatter).not_to receive(:spec_failed)
                  expect(formatter).not_to receive(:spec_failed)
                  expect(formatter).not_to receive(:success)
                  expect(formatter).to receive(:info).with(
                      "Run Jasmine suite spec/javascripts/x/b.js.coffee", { reset: true }
                  )
                  expect(formatter).to receive(:info).with(
                      "Finished in 0.01 seconds"
                  )
                  runner.run(['spec/javascripts/x/b.js.coffee'], { specdoc: :never })
              end
          end

        context 'and console set to :always' do
          it "hides all messages" do
              expect(formatter).not_to receive(:suite_name)
              expect(formatter).not_to receive(:spec_failed)
              expect(formatter).to_not receive(:spec_failed)
              expect(formatter).to_not receive(:suite_name)
              expect(formatter).to_not receive(:spec_failed)
              expect(formatter).to_not receive(:spec_failed)
              expect(formatter).to_not receive(:success)
              expect(formatter).to receive(:info).with(
                  "Run Jasmine suite spec/javascripts/x/b.js.coffee", { reset: true }
              )
              expect(formatter).to receive(:info).with(
                  "Finished in 0.01 seconds"
              )
              runner.run(['spec/javascripts/x/b.js.coffee'], { specdoc: :never, console: :always })
          end
        end
      end

      context 'with the specdoc set either :always or :failure' do
        it 'shows the failed suites' do
          expect(formatter).to receive(:suite_name).with(
            'Failure suite'
          )
          expect(formatter).to receive(:spec_failed).with(
            '  ✘ Failure spec tests something'
          )
          expect(formatter).to receive(:spec_failed).with(
            '    ➤ ReferenceError: Can\'t find variable: a'
          )
          expect(formatter).to receive(:spec_failed).with(
            '      ➜ /path/to/file.js on line 255'
          )
          expect(formatter).to receive(:suite_name).with(
            '  Nested failure suite'
          )
          expect(formatter).to receive(:spec_failed).with(
            '    ✘ Failure spec 2 tests something'
          )
          runner.run(['spec/javascripts/x/b.js.coffee'], { console: :always })
        end

        context 'with focus enabled' do
          context 'and console and error set to :never' do
            it 'does not show the passed specs' do
              expect(formatter).not_to receive(:success).with(
                '    ✔ Success spec tests something'
              )
              expect(formatter).not_to receive(:spec_failed).with(
                '    ➜ Exception: Another error message in /path/to/file.js on line 255'
              )
              expect(formatter).not_to receive(:info).with(
                '      • Another console.log message'
              )
              expect(formatter).not_to receive(:info).with(
                '      • WARN: And even more console.log messages'
              )
              runner.run(['spec/javascripts/x/b.js.coffee'], { console: :never, errors: :never, focus: true })
            end
          end

          context 'and console and errors set to :failure' do
            it 'shows the failed specs with logs' do
              expect(formatter).to receive(:info).with(
                '    • console.log message'
              )
              expect(formatter).to_not receive(:success).with(
                '    ✔ Success spec tests something'
              )
              expect(formatter).to_not receive(:spec_failed).with(
                '    ➜ Exception: Another error message in /path/to/file.js on line 255'
              )
              expect(formatter).to_not receive(:info).with(
                '      • Another console.log message'
              )
              expect(formatter).to_not receive(:info).with(
                '      • WARN: And even more console.log messages'
              )
              runner.run(['spec/javascripts/x/b.js.coffee'], { console: :failure, errors: :failure, focus: true })
            end
          end

          context 'and console set to :always' do
            it 'shows the passed specs with logs' do
              expect(formatter).to_not receive(:success).with(
                '    ✔ Success spec tests something'
              )
              expect(formatter).to_not receive(:spec_failed).with(
                '    ➜ Exception: Another error message in /path/to/file.js on line 255'
              )
              expect(formatter).to_not receive(:info).with(
                '      • Another console.log message'
              )
              expect(formatter).to_not receive(:info).with(
                '      • WARN: And even more console.log messages'
              )
              runner.run(['spec/javascripts/x/b.js.coffee'], { console: :always, errors: :always, focus: true })
            end
          end
        end

        context 'with focus pending' do
          it 'does show the passed specs' do
              expect(formatter).to receive(:info).with(
                  "      • Another console.log message"
              )
              expect(formatter).to receive(:info).with(
                  "      • WARN: And even more console.log messages"
              )
              expect(formatter).to receive(:success).with(
                  '    ✔ Success spec tests something'
              )
            runner.run(['spec/javascripts/x/b.js.coffee'], { console: :always, focus: false })
          end
        end

        context 'with console logs set to :always' do
          it 'shows the failed console logs' do
            expect(formatter).to receive(:info).with(
                  '    • console.log message'
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { console: :always })
          end
        end

        context 'with error logs set to :always' do
          it 'shows the errors logs' do
            expect(formatter).to receive(:spec_failed).with(
              "    ➤ ReferenceError: Can't find variable: a"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { errors: :always })
          end
        end

        context 'with console logs set to :never' do
          it 'does not shows the console logs' do
            expect(formatter).to_not receive(:info).with(
              '    • console.log message'
            )
            expect(formatter).to_not receive(:info).with(
              '      • Another console.log message'
            )
            expect(formatter).to_not receive(:info).with(
              '      • WARN: And even more console.log messages'
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { console: :never })
          end
        end

        context 'with error logs set to :never' do
          it 'does not show the errors logs' do
            expect(formatter).to_not receive(:spec_failed).with(
              '    ➜ Exception: Error message in /path/to/file.js on line 255'
            )
            expect(formatter).to_not receive(:spec_failed).with(
              '    ➜ Exception: Another error message in /path/to/file.js on line 255'
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { errors: :never })
          end
        end

        context 'with console logs set to :failure' do
          it 'shows the console logs for failed specs' do
            expect(formatter).to receive(:info).with(
              '    • console.log message'
            )
            expect(formatter).to_not receive(:info).with(
              '      • WARN: And even more console.log messages'
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { console: :failure })
          end
        end

        context 'with error logs set to :failure' do
          it 'shows the error logs for failed specs' do
            expect(formatter).to receive(:spec_failed).with(
              "    ➤ ReferenceError: Can't find variable: a"
            )
            expect(formatter).to_not receive(:spec_failed).with(
              '    ➜ Exception: Another error message in /path/to/file.js on line 255'
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { errors: :failure })
          end
        end
      end

      context 'with notifications' do
        it 'shows the failing spec notification' do
          expect(formatter).to receive(:notify).with(
                "ReferenceError: Can't find variable: a in /path/to/file.js:255\nExpected true to equal false. in /path/to/file.js:255\nundefined' is not an object (evaluating 'killer.deployRobots') in model_spec.js:27\n4 specs, 1 pending, 2 failures\nin 0.01 seconds",
                title:    'Jasmine suite failed',
                image:    :failed,
                priority: 2
          )
          runner.run(['spec/javascripts/x/b.js.coffee'])
        end

        context 'with :max_error_notify' do
          it 'shows only a single failing spec notification when set to 1' do
            expect(formatter).to receive(:notify).with(
                  "ReferenceError: Can't find variable: a in /path/to/file.js:255\nExpected true to equal false. in /path/to/file.js:255\n4 specs, 1 pending, 2 failures\nin 0.01 seconds",
                  title:    'Jasmine suite failed',
                  image:    :failed, priority: 2
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], max_error_notify: 1 )
          end
          it 'shows two failing specs notification when set to 2' do
              expect(formatter).to receive(:notify).with(
                  "ReferenceError: Can't find variable: a in /path/to/file.js:255\nExpected true to equal false. in /path/to/file.js:255\nundefined' is not an object (evaluating 'killer.deployRobots') in model_spec.js:27\n4 specs, 1 pending, 2 failures\nin 0.01 seconds",
                  title:    'Jasmine suite failed',
                  image:    :failed, priority: 2
              )
              runner.run(['spec/javascripts/x/b.js.coffee'], max_error_notify: 2 )
          end

        end

        context 'without notifications' do
          it 'does not show a failure notification' do
            expect(formatter).to_not receive(:notify)
            runner.run(['spec/javascripts/x/b.js.coffee'], notification: false )
          end
        end
      end
    end

    context 'for a successful Jasmine runner' do
      before do
        allow(File).to receive(:foreach).and_yield 'describe("SuccessTest", function() {'
        allow(IO).to receive(:popen).and_return StringIO.new(phantomjs_success_response)
      end

      it 'requests the jasmine specs from the server' do
        expect(File).to receive(:foreach).with('spec/javascripts/t.js').and_yield 'describe("SuccessTest", function() {'
        expect(IO).to receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=SuccessTest\" 60000 failure true failure failure false true ''", "r:UTF-8")

        runner.run(['spec/javascripts/t.js'])
      end

      it 'returns the success' do
        response = runner.run(['spec/javascripts/x/b.js.coffee'])
        expect(response).to be_empty
      end

      context 'with coverage' do
        context 'when coverage is present' do
          before do
            allow(IO).to receive(:popen).and_return StringIO.new(phantomjs_coverage_response)
            allow(runner).to receive(:coverage_bin).and_return('/bin/istanbul')
            allow(runner).to receive(:coverage_file).and_return('tmp/coverage.json')
            allow(runner).to receive(:coverage_root).and_return('/projects/secret')
          end

          it 'notifies coverage when present' do
            expect(runner).to receive(:notify_coverage_result)
            runner.run(['spec/javascripts/t.js.coffee'], coverage: true )
          end

          context 'checking the coverage' do
            before do
              allow(runner).to receive(:generate_text_report)
            end

            it 'can check for statements coverage' do
              expect(runner).to receive(:`).with('/bin/istanbul check-coverage --statements 12 tmp/coverage.json 2>&1').and_return '' # `
              runner.run(['spec/javascripts/t.js.coffee'], coverage: true, statements_threshold: 12)
            end

            it 'can check for functions coverage' do
              expect(runner).to receive(:`).with('/bin/istanbul check-coverage --functions 12 tmp/coverage.json 2>&1').and_return '' # `
              runner.run(['spec/javascripts/t.js.coffee'], coverage: true, functions_threshold: 12 )
            end

            it 'can check for branches coverage' do
              expect(runner).to receive(:`).with('/bin/istanbul check-coverage --branches 12 tmp/coverage.json 2>&1').and_return '' #`
              runner.run(['spec/javascripts/t.js.coffee'], { coverage: true, branches_threshold: 12 })
            end

            it 'can check for lines coverage' do
              expect(runner).to receive(:`).with('/bin/istanbul check-coverage --lines 12 tmp/coverage.json 2>&1').and_return ''
              runner.run(['spec/javascripts/t.js.coffee'], { coverage: true, lines_threshold: 12 })
            end

            context 'when enough is covered' do
              before do
                expect(runner).to receive(:`).and_return '' # `
              end

              it 'shows the success message' do
                expect(formatter).to receive(:success).with('Code coverage succeed')
                runner.run(['spec/javascripts/t.js.coffee'], { coverage: true, lines_threshold: 12 })
              end

              it 'notifies the coverage success when not turned off' do
                expect(formatter).to receive(:notify).with('All code is adequately covered with specs', title: 'Code coverage succeed')
                runner.run(['spec/javascripts/t.js.coffee'], { coverage: true, lines_threshold: 12 })
              end
            end
          end

          context 'without coverage summary' do
            let(:text_report) do
              <<-EOL
Using reporter [text]
-------------------------------+-----------+-----------+-----------+-----------+
File                           |   % Stmts |% Branches |   % Funcs |   % Lines |
-------------------------------+-----------+-----------+-----------+-----------+
   app/                        |     98.04 |     75.86 |     86.67 |     98.04 |
      test1.js.coffee.erb      |     98.04 |     75.86 |     86.67 |     98.04 |
      test2.js.coffee.erb      |     98.04 |     75.86 |     86.67 |     98.04 |
-------------------------------+-----------+-----------+-----------+-----------+
All files                      |     98.04 |     75.86 |     86.67 |     98.04 |
-------------------------------+-----------+-----------+-----------+-----------+

done
              EOL
            end

            before do
              expect(runner).to receive(:`).with('/bin/istanbul report --root /projects/secret text tmp/coverage.json').and_return text_report # `
              allow(runner).to receive(:check_coverage)
              allow(runner).to receive(:puts)
            end

            it 'shows the summary text info' do
              expect(formatter).to receive(:info).with('Spec coverage details:')
              runner.run(['app/test1.js.coffee'], { coverage: true })
            end


            context 'when running all specs' do
              it 'shows all the important text report entries' do
                expect(runner).to receive(:puts).with ''
                expect(runner).to receive(:puts).with '-------------------------------+-----------+-----------+-----------+-----------+'
                expect(runner).to receive(:puts).with 'File                           |   % Stmts |% Branches |   % Funcs |   % Lines |'
                expect(runner).to receive(:puts).with '-------------------------------+-----------+-----------+-----------+-----------+'
                expect(runner).to receive(:puts).with '   app/                        |     98.04 |     75.86 |     86.67 |     98.04 |'
                expect(runner).to receive(:puts).with '      test1.js.coffee.erb      |     98.04 |     75.86 |     86.67 |     98.04 |'
                expect(runner).to receive(:puts).with '      test2.js.coffee.erb      |     98.04 |     75.86 |     86.67 |     98.04 |'
                expect(runner).to receive(:puts).with '-------------------------------+-----------+-----------+-----------+-----------+'
                expect(runner).to receive(:puts).with 'All files                      |     98.04 |     75.86 |     86.67 |     98.04 |'
                expect(runner).to receive(:puts).with '-------------------------------+-----------+-----------+-----------+-----------+'
                expect(runner).to receive(:puts).with ''
                runner.run(['spec/javascripts'], { coverage: true })
              end
            end

            context 'when running a single spec' do
              it 'shows the single text report entry with its directory' do
                expect(runner).to receive(:puts).with ''
                expect(runner).to receive(:puts).with '-------------------------------+-----------+-----------+-----------+-----------+'
                expect(runner).to receive(:puts).with 'File                           |   % Stmts |% Branches |   % Funcs |   % Lines |'
                expect(runner).to receive(:puts).with '-------------------------------+-----------+-----------+-----------+-----------+'
                expect(runner).to receive(:puts).with '   app/                        |     98.04 |     75.86 |     86.67 |     98.04 |'
                expect(runner).to receive(:puts).with '      test1.js.coffee.erb      |     98.04 |     75.86 |     86.67 |     98.04 |'
                expect(runner).to receive(:puts).with '-------------------------------+-----------+-----------+-----------+-----------+'
                expect(runner).to receive(:puts).with 'All files                      |     98.04 |     75.86 |     86.67 |     98.04 |'
                expect(runner).to receive(:puts).with '-------------------------------+-----------+-----------+-----------+-----------+'
                expect(runner).to receive(:puts).with ''
                runner.run(['app/test1.js.coffee'], { coverage: true })
              end
            end
          end

          context 'with coverage summary' do
            let(:text_summary_report) do
              <<-EOL
Using reporter [text-summary]
Statements   : 98.04% ( 50/51 )
Branches     : 75.86% ( 22/29 )
Functions    : 86.67% ( 13/15 )
Lines        : 98.04% ( 50/51 )

done
              EOL
            end

            before do
              expect(runner).to receive(:`).with('/bin/istanbul report --root /projects/secret text-summary tmp/coverage.json').and_return text_summary_report #`
              allow(runner).to receive(:check_coverage)
              allow(runner).to receive(:puts)
            end

            it 'shows the summary text info' do
              expect(formatter).to receive(:info).with('Spec coverage summary:')
              runner.run(['app/test1.js.coffee'], { coverage: true, coverage_summary: true })
            end

            it 'shows the summary text report' do
              expect(runner).to receive(:puts).with ''
              expect(runner).to receive(:puts).with 'Statements   : 98.04% ( 50/51 )'
              expect(runner).to receive(:puts).with 'Branches     : 75.86% ( 22/29 )'
              expect(runner).to receive(:puts).with 'Functions    : 86.67% ( 13/15 )'
              expect(runner).to receive(:puts).with 'Lines        : 98.04% ( 50/51 )'
              expect(runner).to receive(:puts).with ''
              runner.run(['app/test1.js.coffee'], { coverage: true, coverage_summary: true })
            end
          end

          context 'with coverage html report enabled' do
            before do
              allow(runner).to receive(:generate_text_report)
              allow(runner).to receive(:`) # `
              allow(runner).to receive(:check_coverage)
              allow(runner).to receive(:coverage_report_directory).and_return('/coverage/report/directory')
            end

            it 'generates the html report' do
              expect(runner).to receive(:`).with('/bin/istanbul report --dir /coverage/report/directory --root /projects/secret html tmp/coverage.json') # `
              runner.run(['app/test1.js.coffee'], { coverage: true, coverage_html: true })
            end

            it 'outputs the html report index page' do
              expect(formatter).to receive(:info).with('Updated HTML report available at: /coverage/report/directory/index.html')
              runner.run(['app/test1.js.coffee'], { coverage: true, coverage_html: true })
            end
          end

          context 'with the coverage html directory set' do
            before do
              allow(runner).to receive(:generate_text_report)
              allow(runner).to receive(:`) #`
              allow(runner).to receive(:check_coverage)
            end

            it 'uses the passed in file path' do
              expect(runner).to receive(:coverage_report_directory)
              runner.run(['app/test1.js.coffee'], { coverage: true, coverage_html: true, coverage_html_dir: "test/directory/" })
            end

          end

          context "when istanbul is not found" do
            it "prints an error message telling the user istanbul could not be found" do
              allow(runner).to receive(:coverage_bin).and_return(nil)
              expect(formatter).to receive(:error).with('Skipping coverage report: unable to locate istanbul in your PATH')
              runner.run(['spec/javascripts/t.js.coffee'], { coverage: true, statements_threshold: 12 })
            end
          end
        end
      end

      context 'with the specdoc set to :always' do
        it 'shows the specdoc in the console' do
          expect(formatter).to receive(:info).with(
            'Run Jasmine suite spec/javascripts/x/t.js', { reset: true }
          )
          expect(formatter).to receive(:suite_name).with(
            'Success suite'
          )
          expect(formatter).to receive(:suite_name).with(
            '  Nested success suite'
          )
          expect(formatter).to receive(:success).with(
            "    ✔ Success nested test tests something"
          )
          expect(formatter).to receive(:success).with(
            "3 specs, 0 failures"
          )
          expect(formatter).to receive(:success).with(
            "  ✔ Success test tests something"
          )
          expect(formatter).to receive(:success).with(
            "  ✔ Another success test tests something"
          )
          runner.run(['spec/javascripts/x/t.js'], { specdoc: :always })
        end

        context 'with console logs set to :always' do
          it 'shows the console logs' do
            expect(formatter).to receive(:info).with(
              'Run Jasmine suite spec/javascripts/x/b.js.coffee', { reset: true }
            )
            expect(formatter).to receive(:info).with(
              "    • I can haz console.logs"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { specdoc: :always, console: :always })
          end
        end

        context 'with console logs set to :never' do
          it 'does not shows the console logs' do
            expect(formatter).to_not receive(:info).with(
              "    • I can haz console.logs"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { specdoc: :always, console: :never})
          end
        end
      end

      context 'with the specdoc set to :never or :failure' do
        it 'shows the summary in the console' do
          expect(formatter).to receive(:info).with(
            'Run Jasmine suite spec/javascripts/x/t.js', { reset: true }
          )
          expect(formatter).to_not receive(:suite_name)
          expect(formatter).to receive(:success).with(
            '3 specs, 0 failures'
          )
          runner.run(['spec/javascripts/x/t.js'], { specdoc: :never })
        end

        context 'with console logs set to :always' do
          it 'does not show the console logs' do
            expect(formatter).to_not receive(:info).with(
              '    •  I\'m a nested spec'
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], { console: :always })
          end
        end
      end

      context 'with notifications' do
        it 'shows a success notification' do
          expect(formatter).to receive(:notify).with(
            "3 specs, 0 failures\nin 0.01 seconds",
            title: 'Jasmine suite passed'
          )
          runner.run(['spec/javascripts/t.js'])
        end

        context 'with hide success notifications' do
          it 'does not shows a success notification' do
            expect(formatter).to_not receive(:notify)
            runner.run(['spec/javascripts/t.js'], { notification: true, hide_success: true })
          end
        end
      end

      context 'without notifications' do
        it 'does not shows a success notification' do
          expect(formatter).to_not receive(:notify)
          runner.run(['spec/javascripts/t.js'], { notification: false })
        end
      end
    end

  end

end
