# coding: utf-8

require 'spec_helper'

describe Guard::Jasmine::Server do

  let(:server) { Guard::Jasmine::Server }

  before do
    server.stub(:start_rack_server)
    server.stub(:start_jasmine_gem_server)
    server.stub(:wait_for_server)
  end

  context 'with the :auto strategy' do
    context 'with a rackup config file' do
      before do
        File.should_receive(:exists?).with('config.ru').and_return true
      end

      it 'chooses the rack server strategy' do
        server.should_receive(:start_rack_server)
        server.start(:auto, 8888, 'test')
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(:auto, 8888, 'test')
      end
    end

    context 'with a jasmine config file' do
      before do
        File.should_receive(:exists?).with('config.ru').and_return false
        File.should_receive(:exists?).with(File.join('spec', 'javascripts', 'support', 'jasmine.yml')).and_return true
      end

      it 'chooses the jasmine_gem server strategy' do
        server.should_receive(:start_jasmine_gem_server)
        server.start(:auto, 8888, 'test')
      end

      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(:auto, 8888, 'test')
      end
    end

    context 'without any server config files' do
      before do
        File.should_receive(:exists?).with('config.ru').and_return false
        File.should_receive(:exists?).with(File.join('spec', 'javascripts', 'support', 'jasmine.yml')).and_return false
      end

      it 'does not start a server' do
        server.should_not_receive(:start_rack_server)
        server.should_not_receive(:start_jasmine_gem_server)
        server.should_not_receive(:wait_for_server)
        server.start(:auto, 8888, 'test')
      end
    end
  end

  context 'with the :thin strategy' do
    it 'does not auto detect a server' do
      server.should_not_receive(:detect_server)
      server.start(:thin, 8888, 'test')
    end

    it 'does wait for the server' do
      server.should_receive(:wait_for_server)
      server.start(:thin, 8888, 'test')
    end
  end

  context 'with the :mongrel strategy' do
    it 'does not auto detect a server' do
      server.should_not_receive(:detect_server)
      server.start(:mongrel, 8888, 'test')
    end

    it 'does wait for the server' do
      server.should_receive(:wait_for_server)
      server.start(:mongrel, 8888, 'test')
    end
  end

  context 'with the :webrick strategy' do
    it 'does not auto detect a server' do
      server.should_not_receive(:detect_server)
      server.start(:webrick, 8888, 'test')
    end

    it 'does wait for the server' do
      server.should_receive(:wait_for_server)
      server.start(:webrick, 8888, 'test')
    end
  end

  context 'with the :jasmine_gem strategy' do
    it 'does not auto detect a server' do
      server.should_not_receive(:detect_server)
      server.start(:jasmine_gem, 8888, 'test')
    end

    it 'does wait for the server' do
      server.should_receive(:wait_for_server)
      server.start(:jasmine_gem, 8888, 'test')
    end
  end

  context 'with the :none strategy' do
    it 'does not auto detect a server' do
      server.should_not_receive(:detect_server)
      server.start(:none, 8888, 'test')
    end

    it 'does not start a server' do
      server.should_not_receive(:start_rack_server)
      server.should_not_receive(:start_jasmine_gem_server)
      server.should_not_receive(:wait_for_server)
      server.start(:none, 8888, 'test')
    end
  end

end
