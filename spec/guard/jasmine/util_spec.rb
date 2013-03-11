require 'spec_helper'

describe Guard::Jasmine::Util do
  let(:util) { Class.new { extend Guard::Jasmine::Util } }

  describe '.runner_available?' do
    let(:http) do
      mock('http').tap do |http|
        http.stub(:start).and_yield
        http.stub(:read_timeout=).and_return(nil)
      end
    end

    before do
      Net::HTTP.stub(:new).and_return(http)
    end

    context 'with the Jasmine runner available' do
      before do
        http.stub_chain(:request, :code).and_return 200
      end

      it 'does show that the runner is available' do
        Guard::Jasmine::Formatter.should_receive(:info).with 'Waiting for Jasmine test runner at http://localhost:8888/jasmine'
        util.runner_available?({ :jasmine_url => 'http://localhost:8888/jasmine', :server_timeout => 15 })
      end
    end

    context 'without the Jasmine runner available' do
      context 'because the connection is refused' do
        before do
          http.stub(:start).and_raise Errno::ECONNREFUSED.new
        end

        it 'does show that the runner is not available' do
          Guard::Jasmine::Formatter.should_receive(:error).with 'Jasmine test runner isn\'t available: Connection refused'
          util.runner_available?({ :jasmine_url => 'http://localhost:8888/jasmine', :server_timeout => 15 })
        end
      end

      context 'because the http status is not OK' do
        before do
          http.stub_chain(:request, :code).and_return 404
          http.stub_chain(:request, :body).and_return nil
        end

        it 'does show that the runner is not available' do
          Guard::Jasmine::Formatter.should_receive(:error).with 'Jasmine test runner failed with status 404'
          util.runner_available?({ :jasmine_url => 'http://localhost:8888/jasmine', :server_timeout => 15 })
        end

        context 'with a response body returned' do
          before do
            http.stub_chain(:request, :body).and_return 'Something bad happened'
          end

          it 'outputs the body for further analysis' do
            Guard::Jasmine::Formatter.should_receive(:error).with 'Jasmine test runner failed with status 404'
            Guard::Jasmine::Formatter.should_receive(:error).with 'Please open the Jasmine runner in your browser for more information.'
            util.runner_available?({ :jasmine_url => 'http://localhost:8888/jasmine', :server_timeout => 15 })
          end
        end
      end

      context 'because a timeout occurs' do
        before do
          http.stub(:start).and_raise(Timeout::Error)
        end

        it 'does show that the runner is not available' do
          Guard::Jasmine::Formatter.should_receive(:error).with 'Timeout waiting for the Jasmine test runner.'
          util.runner_available?({ :jasmine_url => 'http://localhost:8888/jasmine', :server_timeout => 15 })
        end
      end
    end
  end

  describe '.phantomjs_bin_valid?' do
    context 'without a phantomjs bin' do
      it 'shows a message that the executable is missing' do
        Guard::Jasmine::Formatter.should_receive(:error).with 'PhantomJS executable couldn\'t be auto detected.'
        util.phantomjs_bin_valid?(nil)
      end
    end

    context 'with a missing PhantomJS executable' do
      before do
        util.stub(:`).and_return nil
      end

      it 'shows a message that the executable is missing' do
        Guard::Jasmine::Formatter.should_receive(:error).with 'PhantomJS executable doesn\'t exist at /usr/bin/phantomjs'
        util.phantomjs_bin_valid?('/usr/bin/phantomjs')
      end
    end

    context 'with a something other than a valid PhantomJS version' do
      before do
        util.stub(:`).and_return 'Command not found'
      end

      it 'shows a message that the version is wrong' do
        Guard::Jasmine::Formatter.should_receive(:error).with 'PhantomJS reports unknown version format: Command not found'
        util.phantomjs_bin_valid?('/usr/bin/phantomjs')
      end
    end

    context 'with a wrong PhantomJS version' do
      before do
        util.stub(:`).and_return '1.1.0'
      end

      it 'shows a message that the version is wrong' do
        Guard::Jasmine::Formatter.should_receive(:error).with 'PhantomJS executable at /usr/bin/phantomjs must be at least version 1.3.0'
        util.phantomjs_bin_valid?('/usr/bin/phantomjs')
      end
    end
  end

end
