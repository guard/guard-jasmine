# coding: utf-8

require 'spec_helper'

describe Guard::Jasmine::Server do

  let(:server) { Guard::Jasmine::Server }

  let(:defaults) do
    {
      server:     :auto,
      port:       8888,
      server_env: 'test',
      spec_dir:   'spec/javascripts'
    }
  end

  before do
    server.stub(:start_rack_server)
    server.stub(:start_rake_server)
    server.stub(:wait_for_server)
  end

  describe '.start' do
    context 'with the :thin strategy' do
      let(:options) do
        defaults.merge({ server: :thin })
      end

      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(options)
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(options)
      end

      it 'starts a :thin rack server' do
        server.should_receive(:start_rack_server).with(:thin, 8888, options)
        server.start(options)
      end
    end

    context 'with the :puma strategy' do
      let(:options) do
        defaults.merge({ server: :puma })
      end

      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(options)
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(options)
      end

      it 'starts a :puma rack server' do
        server.should_receive(:start_rack_server).with(:puma, 8888, options)
        server.start(options)
      end
    end

    context 'with the :mongrel strategy' do
      let(:options) do
        defaults.merge({ server: :mongrel })
      end

      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(options)
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(options)
      end

      it 'starts a :mongrel rack server' do
        server.should_receive(:start_rack_server).with(:mongrel, 8888, options)
        server.start(options)
      end
    end

    context 'with the :webrick strategy' do
      let(:options) do
        defaults.merge({ server: :webrick })
      end

      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(options)
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(options)
      end

      it 'starts a :webrick rack server' do
        server.should_receive(:start_rack_server).with(:webrick, 8888, options)
        server.start(options)
      end
    end

    context 'with the :unicorn strategy' do
      let(:options) do
        defaults.merge({ server: :unicorn })
      end

      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(options)
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(options)
      end

      it 'starts a Unicorn Rails server' do
        server.should_receive(:start_unicorn_server).with(8888, options)
        server.start(options)
      end
    end

    context 'with the :webrick strategy and a custom config.ru' do
      let(:options) do
        defaults.merge({ server: :webrick, rackup_config: 'my/cool.ru' })
      end

      it 'starts a :webrick rack server' do
        server.should_receive(:start_rack_server).with(:webrick, 8888, options)
        server.start(options)
      end
    end

    context 'with the :jasmine_gem strategy' do
      let(:options) do
        defaults.merge({ server: :jasmine_gem })
      end

      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(options)
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(options)
      end

      it 'starts the :jasmine rake task server' do
        server.should_receive(:start_rake_server).with(8888, 'jasmine', options)
        server.start(options)
      end
    end

    context 'with a custom rake strategy' do
      let(:options) do
        defaults.merge({ server: :custom_server_strategy })
      end

      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(options)
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(options)
      end

      it 'starts a custom rake task server' do
        server.should_receive(:start_rake_server).with(8888, 'custom_server_strategy', options)
        server.start(options)
      end
    end

    context 'with the :none strategy' do
      let(:options) do
        defaults.merge({ server: :none })
      end

      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(options)
      end

      it 'does not start a server' do
        server.should_not_receive(:start_rack_server)
        server.should_not_receive(:start_rake_server)
        server.should_not_receive(:wait_for_server)
        server.start(options)
      end
    end
  end

  describe '.detect_server' do
    context 'with a `config.ru` file' do
      before do
        File.should_receive(:exists?).with('config.ru').and_return true
      end

      context 'with unicorn available' do
        before do
          Guard::Jasmine::Server.should_receive(:require).with('unicorn').and_return true
        end

        it 'returns `:unicorn` as server' do
          server.detect_server('spec/javascripts').should eql(:unicorn)
        end
      end

      context 'with thin available' do
        before do
          Guard::Jasmine::Server.should_receive(:require).with('unicorn').and_raise LoadError
          Guard::Jasmine::Server.should_receive(:require).with('thin').and_return true
        end

        it 'returns `:thin` as server' do
          server.detect_server('spec/javascripts').should eql(:thin)
        end
      end

      context 'with mongrel available' do
        before do
          Guard::Jasmine::Server.should_receive(:require).with('unicorn').and_raise LoadError
          Guard::Jasmine::Server.should_receive(:require).with('thin').and_raise LoadError
          Guard::Jasmine::Server.should_receive(:require).with('mongrel').and_return true
        end

        it 'returns `:mongrel` as server' do
          server.detect_server('spec/javascripts').should eql(:mongrel)
        end
      end

      context 'with puma available' do
        before do
          Guard::Jasmine::Server.should_receive(:require).with('unicorn').and_raise LoadError
          Guard::Jasmine::Server.should_receive(:require).with('thin').and_raise LoadError
          Guard::Jasmine::Server.should_receive(:require).with('mongrel').and_raise LoadError
          Guard::Jasmine::Server.should_receive(:require).with('puma').and_return true
        end

        it 'returns `:puma` as server' do
          server.detect_server('spec/javascripts').should eql(:puma)
        end
      end
    end

    context 'with a `support/jasmine.yml` file in the spec folder' do
      before do
        File.should_receive(:exists?).with('config.ru').and_return false
        File.should_receive(:exists?).with(File.join('spec', 'javascripts', 'support', 'jasmine.yml')).and_return true
      end

      it 'returns `:jasmine_gem` as server' do
        server.detect_server('spec/javascripts').should eql(:jasmine_gem)
      end
    end

    context 'without a recognized server configuration' do
      it 'returns `:none` as server' do
        server.detect_server('spec/javascripts').should eql(:none)
      end
    end
  end
end
