require 'spec_helper'

describe Guard::Jasmine::Runner do

  let(:runner) { Guard::Jasmine::Runner }
  let(:formatter) { Guard::Jasmine::Formatter }

  let(:defaults) do
    {
        :jasmine_url   => 'http://localhost:3000/jasmine',
        :phantomjs_bin => '/usr/local/bin/phantomjs',
        :notification  => true,
        :hide_success  => false
    }
  end

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
      "failed": [
        {
          "description": "FailureTest",
          "filter": "?spec=FailureTest",
          "specs": [
            {
              "description": "FailureTest tests something.",
              "error_message": "Expected undefined to be defined."
            }
          ]
        }
      ],
      "stats": {
        "specs": 4,
        "failures": 1,
        "time": 0.007
      }
    }
    JSON
  end

  let(:phantomjs_success_response) do
    <<-JSON
    {
      "stats": {
        "specs": 4,
        "failures": 0,
        "time": 0.009
      }
    }
    JSON
  end

  let(:phantomjs_command) do
    "/usr/local/bin/phantomjs #{ @project_path }/lib/guard/jasmine/phantomjs/run-jasmine.coffee"
  end

  before do
    formatter.stub(:notify)
  end

  describe '#run' do
    before do
      File.stub(:foreach).and_yield 'describe "ErrorTest", ->'
      IO.stub(:popen).and_return StringIO.new(phantomjs_error_response)
    end

    context 'when passed an empty paths list' do
      it 'returns false' do
        runner.run([]).should eql [false, []]
      end
    end

    context 'when passed the spec directory' do
      it 'requests all jasmine specs from the server' do
        IO.should_receive(:popen).with("#{ phantomjs_command } http://localhost:3000/jasmine")
        runner.run(['spec/javascripts'], { :notification => false }.merge(defaults))
      end
    end

    context 'for an erroneous Jasmine spec' do
      it 'requests the jasmine specs from the server' do
        IO.should_receive(:popen).with("#{ phantomjs_command } http://localhost:3000/jasmine?spec=ErrorTest")
        runner.run(['spec/javascripts/a.js.coffee'], { :notification => false }.merge(defaults))
      end

      it 'shows the error in the console' do
        formatter.should_receive(:error).with(
            "An error occurred: Cannot request Jasmine specs"
        )
        runner.run(['spec/javascripts/a.js.coffee'], defaults.merge({ :notification => false }))
      end

      it 'returns the errors' do
        response = runner.run(['spec/javascripts/a.js.coffee'], { :notification => false }.merge(defaults))
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
          runner.run(['spec/javascripts/a.js.coffee'], defaults.merge({ :notification => true }))
        end
      end

      context 'without notifications' do
        it 'does not shows an error notification' do
          formatter.should_not_receive(:notify)
          runner.run(['spec/javascripts/a.js.coffee'], defaults.merge({ :notification => false }))
        end
      end
    end

    context "for a failing Jasmine spec" do
      before do
        File.stub(:foreach).and_yield 'describe "FailureTest", ->'
        IO.stub(:popen).and_return StringIO.new(phantomjs_failure_response)
      end

      it 'requests the jasmine specs from the server' do
        File.should_receive(:foreach).with('spec/javascripts/x/b.js.coffee').and_yield 'describe "FailureTest", ->'
        IO.should_receive(:popen).with("#{ phantomjs_command } http://localhost:3000/jasmine?spec=FailureTest")
        runner.run(['spec/javascripts/x/b.js.coffee'], { :notification => false }.merge(defaults))
      end

      it 'shows the failure in the console' do
        formatter.should_receive(:error).with(
            "Spec 'FailureTest tests something.' failed with 'Expected undefined to be defined.'!\nJasmine ran 4 specs, 1 failure in 0.007s."
        )
        runner.run(['spec/javascripts/x/b.js.coffee'], { :notification => false }.merge(defaults))
      end

      it 'returns the failures' do
        response = runner.run(['spec/javascripts/x/b.js.coffee'], { :notification => false }.merge(defaults))
        response.first.should be_false
        response.last.should =~ ['spec/javascripts/x/b.js.coffee']
      end

      context 'with notifications' do
        it 'shows a failure notification' do
          formatter.should_receive(:notify).with(
              "Spec 'FailureTest tests something.' failed with 'Expected undefined to be defined.'!\nJasmine ran 4 specs, 1 failure in 0.007s.",
              :title    => 'Jasmine results',
              :image    => :failed,
              :priority => 2
          )
          runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :notification => true }))
        end
      end

      context 'without notifications' do
        it 'does not show a failure notification' do
          formatter.should_not_receive(:notify)
          runner.run(['spec/javascripts/x/b.js.coffee'], defaults.merge({ :notification => false }))
        end
      end
    end

    context "for a successful Jasmine spec" do
      before do
        File.stub(:foreach).and_yield 'describe("SuccessTest", function() {'
        IO.stub(:popen).and_return StringIO.new(phantomjs_success_response)
      end

      it 'requests the jasmine specs from the server' do
        File.should_receive(:foreach).with('spec/javascripts/t.js').and_yield 'describe("SuccessTest", function() {'
        IO.should_receive(:popen).with("#{ phantomjs_command } http://localhost:3000/jasmine?spec=SuccessTest")

        runner.run(['spec/javascripts/t.js'], defaults.merge({ :notification => false }))
      end

      it 'shows the success in the console' do
        formatter.should_receive(:success).with(
            "Jasmine ran 4 specs, 0 failures in 0.009s."
        )
        runner.run(['spec/javascripts/t.js'], defaults.merge({ :notification => false }))
      end

      it 'returns the success' do
        response = runner.run(['spec/javascripts/x/b.js.coffee'], { :notification => false }.merge(defaults))
        response.first.should be_true
        response.last.should =~ []
      end

      context 'with notifications' do
        it 'shows a success notification' do
          formatter.should_receive(:notify).with(
              "Jasmine ran 4 specs, 0 failures in 0.009s.",
              :title => 'Jasmine results'
          )
          runner.run(['spec/javascripts/t.js'], defaults.merge({ :notification => true }))
        end

        context 'with hide success notifications' do
          it 'des not shows a success notification' do
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
