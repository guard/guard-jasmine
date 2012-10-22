# coding: utf-8

require 'spec_helper'

describe Guard::Jasmine::Runner do

  let(:runner) { Guard::Jasmine::Runner }
  let(:formatter) { Guard::Jasmine::Formatter }

  let(:defaults) { Guard::Jasmine::DEFAULT_OPTIONS.merge({ :phantomjs_bin => '/usr/local/bin/phantomjs' }) }

  let(:phantomjs_error_response) do
    <<-JSON
    {
      "error": "Cannot request Jasmine specs"
    }
    JSON
  end

  let(:phantomjs_failure_response) do
    <<-JSON
    {
      "passed": false,
      "stats": {
        "specs": 3,
        "failures": 2,
        "time": 0.007
      },
      "suites": [
        {
          "description": "Failure suite",
          "specs": [
            {
              "description": "Failure spec tests something",
              "messages": [
                "ReferenceError: Can't find variable: a in http://localhost:8888/assets/backbone/models/model_spec.js?body=1 (line 27)"
              ],
              "logs": [
                "console.log message"
              ],
              "errors": [
                {
                  "msg": "Error message",
                  "trace" : [{
                    "file": "/path/to/file.js",
                    "line": "255"
                  }]
                }
              ],
              "passed": false
            }
          ],
          "suites": [
            {
              "description": "Nested failure suite",
              "specs": [
                {
                  "description": "Failure spec 2 tests something",
                  "messages": [
                    "ReferenceError: Can't find variable: b in http://localhost:8888/assets/backbone/models/model_spec.js?body=1 (line 27)"
                  ],
                  "passed": false
                },
                {
                  "description": "Success spec tests something",
                  "passed": true,
                  "logs": [
                    "Another console.log message",
                    "And even more console.log messages"
                  ],
                  "errors": [
                    {
                      "msg": "Another error message",
                      "trace" : [{
                        "file": "/path/to/file.js",
                        "line": "255"
                      }]
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
    JSON
  end

  let(:phantomjs_success_response) do
    <<-JSON
    {
      "passed": true,
      "stats": {
        "specs": 3,
        "failures": 0,
        "time": 0.009
      },
      "suites": [
        {
          "description": "Success suite",
          "specs": [
            {
              "description": "Success test tests something",
              "passed": true
            },
            {
              "description": "Another success test tests something",
              "passed": true,
              "logs": [
                "I can haz console.logs"
              ]
            }
          ],
          "suites": [
            {
              "description": "Nested success suite",
              "specs": [
                {
                  "description": "Success nested test tests something",
                  "passed": true
                }
              ]
            }
          ]
        }
      ]
    }
    JSON
  end

  let(:phantomjs_command) do
    "/usr/local/bin/phantomjs #{ @project_path }/lib/guard/jasmine/phantomjs/guard-jasmine.js"
  end

  before do
    formatter.stub(:info)
    formatter.stub(:debug)
    formatter.stub(:error)
    formatter.stub(:success)
    formatter.stub(:spec_failed)
    formatter.stub(:suite_name)
    formatter.stub(:notify)
  end

  describe '#run' do
    before do
      File.stub(:foreach).and_yield 'describe "ErrorTest", ->'
      File.stub(:exist?).and_return(true)
      IO.stub(:popen).and_return StringIO.new(phantomjs_error_response)
    end

    context 'when passed an empty paths list' do
      it 'returns false' do
        runner.run([]).should eql [false, []]
      end
    end

    context 'when the spec file does not exist' do
      it 'does nothing' do
        File.stub(:exist?).with('spec/javascripts').and_return(false)
        runner.should_not_receive(:evaluate_response)
        runner.run(['spec/javascripts'])
      end
    end

    context 'when passed the spec directory' do
      it 'requests all jasmine specs from the server' do
        IO.should_receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine\" 10000 failure true failure failure", "r:UTF-8")
        runner.run(['spec/javascripts'], defaults.merge({ :notification => false }))
      end

      it 'shows a start information in the console' do
        formatter.should_receive(:info).with('Run all Jasmine suites', { :reset => true })
        formatter.should_receive(:info).with('Run Jasmine suite at http://localhost:8888/jasmine')
        runner.run(['spec/javascripts'], defaults)
      end
    end

    context 'for an erroneous Jasmine runner' do
      it 'requests the jasmine specs from the server' do
        IO.should_receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=ErrorTest\" 10000 failure true failure failure", "r:UTF-8")
        runner.run(['spec/javascripts/a.js.coffee'], defaults)
      end

      it 'shows the error in the console' do
        formatter.should_receive(:error).with(
            "An error occurred: Cannot request Jasmine specs"
        )
        runner.run(['spec/javascripts/a.js.coffee'], defaults)
      end

      it 'returns the errors' do
        response = runner.run(['spec/javascripts/a.js.coffee'], defaults)
        response.first.should be_false
        response.last.should =~ []
      end

      context 'with notifications' do
        it 'shows an error notification' do
          formatter.should_receive(:notify).with(
              "An error occurred: Cannot request Jasmine specs",
              :title    => 'Jasmine error',
              :image    => :failed,
              :priority => 2
          )
          runner.run(['spec/javascripts/a.js.coffee'], defaults)
        end
      end

      context 'without notifications' do
        it 'does not shows an error notification' do
          formatter.should_not_receive(:notify)
          runner.run(['spec/javascripts/a.js.coffee'], defaults.merge({ :notification => false }))
        end
      end
    end

    context "for a failing Jasmine runner" do
      before do
        File.stub(:foreach).and_yield 'describe "FailureTest", ->'
        IO.stub(:popen).and_return StringIO.new(phantomjs_failure_response)
      end

      it 'requests the jasmine specs from the server' do
        File.should_receive(:foreach).with('spec/javascripts/x/b.js.coffee').and_yield 'describe "FailureTest", ->'
        IO.should_receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=FailureTest\" 10000 failure true failure failure", "r:UTF-8")
        runner.run(['spec/javascripts/x/b.js.coffee'], defaults)
      end

      it 'returns the failures' do
        response = runner.run(['spec/javascripts/x/b.js.coffee'], defaults)
        response.first.should be_false
        response.last.should =~ ['spec/javascripts/x/b.js.coffee']
      end

      context 'with the specdoc set to :never' do
        context 'and console and errors set to :never' do
          it 'shows the summary in the console' do
            formatter.should_receive(:info).with(
                'Run Jasmine suite spec/javascripts/x/b.js.coffee', { :reset => true }
            )
            formatter.should_receive(:info).with(
                'Run Jasmine suite at http://localhost:8888/jasmine?spec=FailureTest'
            )
            formatter.should_not_receive(:suite_name)
            formatter.should_not_receive(:spec_failed)
            formatter.should_receive(:error).with(
                "3 specs, 2 failures"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :specdoc => :never, :console => :never, :errors => :never }))
          end
        end

        context 'and console set to :failure' do
          it 'shows the suites with log messages for failures' do
            formatter.should_receive(:suite_name).with(
                'Failure suite'
            )
            formatter.should_receive(:spec_failed).with(
                '  ✘ Failure spec tests something'
            )
            formatter.should_not_receive(:spec_failed).with(
                '    ➤ ReferenceError: Can\'t find variable: a in backbone/models/model_spec.js on line 27'
            )
            formatter.should_receive(:info).with(
                '    • console.log message'
            )
            formatter.should_not_receive(:suite_name).with(
                '  Nested failure suite'
            )
            formatter.should_not_receive(:spec_failed).with(
                '    ✘ Failure spec 2 tests something'
            )
            formatter.should_not_receive(:spec_failed).with(
                '      ➤ ReferenceError: Can\'t find variable: b in backbone/models/model_spec.js on line 27'
            )
            formatter.should_not_receive(:success).with(
                '    ✔ Success spec tests something'
            )
            formatter.should_not_receive(:info).with(
                '      • Another console.log message'
            )
            formatter.should_not_receive(:info).with(
                '      • And even more console.log messages'
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :specdoc => :never }))
          end
        end

        context 'and console set to :always' do
          it 'shows the suites with all log messages' do
            formatter.should_receive(:suite_name).with(
                'Failure suite'
            )
            formatter.should_receive(:spec_failed).with(
                '  ✘ Failure spec tests something'
            )
            formatter.should_not_receive(:spec_failed).with(
                '    ➤ ReferenceError: Can\'t find variable: a in backbone/models/model_spec.js on line 27'
            )
            formatter.should_receive(:info).with(
                '    • console.log message'
            )
            formatter.should_receive(:suite_name).with(
                '  Nested failure suite'
            )
            formatter.should_not_receive(:spec_failed).with(
                '    ✘ Failure spec 2 tests something'
            )
            formatter.should_not_receive(:spec_failed).with(
                '      ➤ ReferenceError: Can\'t find variable: b in backbone/models/model_spec.js on line 27'
            )
            formatter.should_receive(:success).with(
                '    ✔ Success spec tests something'
            )
            formatter.should_receive(:info).with(
                '      • Another console.log message'
            )
            formatter.should_receive(:info).with(
                '      • And even more console.log messages'
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :specdoc => :never, :console => :always }))
          end
        end
      end

      context 'with the specdoc set either :always or :failure' do
        it 'shows the failed suites' do
          formatter.should_receive(:suite_name).with(
              'Failure suite'
          )
          formatter.should_receive(:spec_failed).with(
              '  ✘ Failure spec tests something'
          )
          formatter.should_receive(:spec_failed).with(
              "    ➤ ReferenceError: Can't find variable: a in backbone/models/model_spec.js on line 27"
          )
          formatter.should_receive(:suite_name).with(
              '  Nested failure suite'
          )
          formatter.should_receive(:spec_failed).with(
              '    ✘ Failure spec 2 tests something'
          )
          formatter.should_receive(:spec_failed).with(
              "      ➤ ReferenceError: Can't find variable: b in backbone/models/model_spec.js on line 27"
          )
          runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :always }))
        end

        context 'with focus enabled' do
          context 'and console and error set to :never' do
            it 'does not show the passed specs' do
              formatter.should_not_receive(:success).with(
                  '    ✔ Success spec tests something'
              )
              formatter.should_not_receive(:spec_failed).with(
                  "    ➜ Exception: Another error message in /path/to/file.js on line 255"
              )
              formatter.should_not_receive(:info).with(
                  "      • Another console.log message"
              )
              formatter.should_not_receive(:info).with(
                  "      • And even more console.log messages"
              )
              runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :never, :errors => :never, :focus => true }))
            end
          end

          context 'and console and errors set to :failure' do
            it 'shows the failed specs with logs' do
              formatter.should_receive(:info).with(
                  "    • console.log message"
              )
              formatter.should_not_receive(:success).with(
                  '    ✔ Success spec tests something'
              )
              formatter.should_not_receive(:spec_failed).with(
                  "    ➜ Exception: Another error message in /path/to/file.js on line 255"
              )
              formatter.should_not_receive(:info).with(
                  "      • Another console.log message"
              )
              formatter.should_not_receive(:info).with(
                  "      • And even more console.log messages"
              )
              runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :failure, :errors => :failure, :focus => true }))
            end
          end

          context 'and console set to :always' do
            it 'shows the passed specs with logs' do
              formatter.should_receive(:info).with(
                  "    • console.log message"
              )
              formatter.should_receive(:success).with(
                  '    ✔ Success spec tests something'
              )
              formatter.should_not_receive(:spec_failed).with(
                  "    ➜ Exception: Another error message in /path/to/file.js on line 255"
              )
              formatter.should_receive(:info).with(
                  "      • Another console.log message"
              )
              formatter.should_receive(:info).with(
                  "      • And even more console.log messages"
              )
              runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :always, :errors => :always, :focus => true }))
            end
          end
        end

        context 'with focus disabled' do
          it 'does show the passed specs' do
            formatter.should_receive(:success).with(
                '    ✔ Success spec tests something'
            )
            formatter.should_receive(:info).with(
                "      • Another console.log message"
            )
            formatter.should_receive(:info).with(
                "      • And even more console.log messages"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :always, :focus => false }))
          end
        end

        context 'with console logs set to :always' do
          it 'shows the failed console logs' do
            formatter.should_receive(:info).with(
                "    • console.log message"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :always }))
          end
        end

        context 'with error logs set to :always' do
          it 'shows the errors logs' do
            formatter.should_receive(:spec_failed).with(
                "    ➜ Exception: Error message in /path/to/file.js on line 255"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :errors => :always }))
          end
        end

        context 'with console logs set to :never' do
          it 'does not shows the console logs' do
            formatter.should_not_receive(:info).with(
                "    • console.log message"
            )
            formatter.should_not_receive(:info).with(
                "      • Another console.log message"
            )
            formatter.should_not_receive(:info).with(
                "      • And even more console.log messages"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :never }))
          end
        end

        context 'with error logs set to :never' do
          it 'does not show the errors logs' do
            formatter.should_not_receive(:spec_failed).with(
                "    ➜ Exception: Error message in /path/to/file.js on line 255"
            )
            formatter.should_not_receive(:spec_failed).with(
                "    ➜ Exception: Another error message in /path/to/file.js on line 255"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :errors => :never }))
          end
        end

        context 'with console logs set to :failure' do
          it 'shows the console logs for failed specs' do
            formatter.should_receive(:info).with(
                "    • console.log message"
            )
            formatter.should_not_receive(:info).with(
                "      • Another console.log message"
            )
            formatter.should_not_receive(:info).with(
                "      • And even more console.log messages"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :failure }))
          end
        end

        context 'with error logs set to :failure' do
          it 'shows the error logs for failed specs' do
            formatter.should_receive(:spec_failed).with(
                "    ➜ Exception: Error message in /path/to/file.js on line 255"
            )
            formatter.should_not_receive(:spec_failed).with(
                "    ➜ Exception: Another error message in /path/to/file.js on line 255"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :errors => :failure }))
          end
        end
      end

      context 'with notifications' do
        it 'shows the failing spec notification' do
          formatter.should_receive(:notify).with(
              "Failure spec tests something: ReferenceError: Can't find variable: a",
              :title    => 'Jasmine spec failed',
              :image    => :failed,
              :priority => 2
          )
          formatter.should_receive(:notify).with(
              "Failure spec 2 tests something: ReferenceError: Can't find variable: b",
              :title    => 'Jasmine spec failed',
              :image    => :failed,
              :priority => 2
          )
          formatter.should_receive(:notify).with(
              "3 specs, 2 failures\nin 0.007 seconds",
              :title    => 'Jasmine suite failed',
              :image    => :failed,
              :priority => 2
          )
          runner.run(['spec/javascripts/x/b.js.coffee'], defaults)
        end

        context 'with :max_error_notify' do
          it 'shows the failing spec notification' do
            formatter.should_receive(:notify).with(
                "Failure spec tests something: ReferenceError: Can't find variable: a",
                :title    => 'Jasmine spec failed',
                :image    => :failed,
                :priority => 2
            )
            formatter.should_not_receive(:notify).with(
                "Failure spec 2 tests something: ReferenceError: Can't find variable: b",
                :title    => 'Jasmine spec failed',
                :image    => :failed,
                :priority => 2
            )
            formatter.should_receive(:notify).with(
                "3 specs, 2 failures\nin 0.007 seconds",
                :title    => 'Jasmine suite failed',
                :image    => :failed,
                :priority => 2
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :max_error_notify => 1 }))
          end
        end

        context 'without notifications' do
          it 'does not show a failure notification' do
            formatter.should_not_receive(:notify)
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :notification => false }))
          end
        end
      end
    end

    context "for a successful Jasmine runner" do
      before do
        File.stub(:foreach).and_yield 'describe("SuccessTest", function() {'
        IO.stub(:popen).and_return StringIO.new(phantomjs_success_response)
      end

      it 'requests the jasmine specs from the server' do
        File.should_receive(:foreach).with('spec/javascripts/t.js').and_yield 'describe("SuccessTest", function() {'
        IO.should_receive(:popen).with("#{ phantomjs_command } \"http://localhost:8888/jasmine?spec=SuccessTest\" 10000 failure true failure failure", "r:UTF-8")

        runner.run(['spec/javascripts/t.js'], defaults)
      end

      it 'returns the success' do
        response = runner.run(['spec/javascripts/x/b.js.coffee'], defaults)
        response.first.should be_true
        response.last.should =~ []
      end

      context 'with the specdoc set to :always' do
        it 'shows the specdoc in the console' do
          formatter.should_receive(:info).with(
              'Run Jasmine suite spec/javascripts/x/t.js', { :reset => true }
          )
          formatter.should_receive(:info).with(
              'Run Jasmine suite at http://localhost:8888/jasmine?spec=SuccessTest'
          )
          formatter.should_receive(:suite_name).with(
              'Success suite'
          )
          formatter.should_receive(:success).with(
              '  ✔ Success test tests something'
          )
          formatter.should_receive(:success).with(
              '  ✔ Another success test tests something'
          )
          formatter.should_receive(:suite_name).with(
               '  Nested success suite'
           )
          formatter.should_receive(:success).with(
              '    ✔ Success nested test tests something'
          )
          formatter.should_receive(:success).with(
              "3 specs, 0 failures"
          )
          runner.run(['spec/javascripts/x/t.js'], defaults.merge({ :specdoc => :always }))
        end

        context 'with console logs set to :always' do
          it 'shows the console logs' do
            formatter.should_receive(:info).with(
                'Run Jasmine suite spec/javascripts/x/b.js.coffee', { :reset => true }
            )
            formatter.should_receive(:info).with(
                'Run Jasmine suite at http://localhost:8888/jasmine?spec=SuccessTest'
            )
            formatter.should_receive(:info).with(
                "    • I can haz console.logs"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :specdoc => :always, :console => :always }))
          end
        end

        context 'with console logs set to :never' do
          it 'does not shows the console logs' do
            formatter.should_not_receive(:info).with(
                "    • I can haz console.logs"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :specdoc => :always, :console => :never }))
          end
        end
      end

      context 'with the specdoc set to :never or :failure' do
        it 'shows the summary in the console' do
          formatter.should_receive(:info).with(
              'Run Jasmine suite spec/javascripts/x/t.js', { :reset => true }
          )
          formatter.should_receive(:info).with(
              'Run Jasmine suite at http://localhost:8888/jasmine?spec=SuccessTest'
          )
          formatter.should_not_receive(:suite_name)
          formatter.should_receive(:success).with(
              "3 specs, 0 failures"
          )
          runner.run(['spec/javascripts/x/t.js'], defaults.merge({ :specdoc => :never }))
        end

        context 'with console logs set to :always' do
          it 'shows the console logs' do
            formatter.should_receive(:info).with(
                "    • I can haz console.logs"
            )
            runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :console => :always }))
          end
        end
      end

      context 'with notifications' do
        it 'shows a success notification' do
          formatter.should_receive(:notify).with(
              "3 specs, 0 failures\nin 0.009 seconds",
              :title => 'Jasmine suite passed'
          )
          runner.run(['spec/javascripts/t.js'], defaults)
        end

        context 'with hide success notifications' do
          it 'does not shows a success notification' do
            formatter.should_not_receive(:notify)
            runner.run(['spec/javascripts/t.js'], defaults.merge({ :notification => true, :hide_success => true }))
          end
        end
      end

      context 'without notifications' do
        it 'does not shows a success notification' do
          formatter.should_not_receive(:notify)
          runner.run(['spec/javascripts/t.js'], defaults.merge({ :notification => false }))
        end
      end
    end

  end

end
