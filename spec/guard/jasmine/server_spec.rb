# coding: utf-8

require 'spec_helper'

describe Guard::Jasmine::Server do

  let(:server) { Guard::Jasmine::Server }

  before do
    server.stub(:start_rack_server)
    server.stub(:start_rake_server)
    server.stub(:wait_for_server)
  end

  describe '#start' do
    context 'with the :auto strategy' do
      context 'with a rackup config file' do
        before do
          File.should_receive(:exists?).with('config.ru').and_return true
        end
  
        it 'does wait for the server' do
          server.should_receive(:wait_for_server)
          server.start(:auto, 8888, 'test', 'spec/javascripts')
        end
  
        context 'with unicorn available' do
          before do
            Guard::Jasmine::Server.should_receive(:require).with('unicorn').and_return true  
          end
          
          it 'uses unicorn as server' do
            server.should_receive(:start_rack_server).with(8888, 'test', :unicorn, nil)
            server.start(:auto, 8888, 'test', 'spec/javascripts')
          end
        end
  
        context 'with thin available' do
          before do
            Guard::Jasmine::Server.should_receive(:require).with('unicorn').and_raise LoadError
            Guard::Jasmine::Server.should_receive(:require).with('thin').and_return true
          end
  
          it 'uses thin as server' do
            server.should_receive(:start_rack_server).with(8888, 'test', :thin, nil)
            server.start(:auto, 8888, 'test', 'spec/javascripts')
          end
        end
  
        context 'with mongrel available' do
          before do
            Guard::Jasmine::Server.should_receive(:require).with('unicorn').and_raise LoadError
            Guard::Jasmine::Server.should_receive(:require).with('thin').and_raise LoadError
            Guard::Jasmine::Server.should_receive(:require).with('mongrel').and_return true
          end
  
          it 'uses mongrel as server' do
            server.should_receive(:start_rack_server).with(8888, 'test', :mongrel, nil)
            server.start(:auto, 8888, 'test', 'spec/javascripts')
          end
        end
  
        context 'with unicorn, thin or mongrel not being available' do
          before do
            Guard::Jasmine::Server.should_receive(:require).with('unicorn').and_raise LoadError
            Guard::Jasmine::Server.should_receive(:require).with('thin').and_raise LoadError
            Guard::Jasmine::Server.should_receive(:require).with('mongrel').and_raise LoadError
          end
  
          it 'uses webrick as server' do
            server.should_receive(:start_rack_server).with(8888, 'test', :webrick, nil)
            server.start(:auto, 8888, 'test', 'spec/javascripts')
          end
        end
      end
  
      context 'with a jasmine config file' do
        context 'with the default spec dir' do
          before do
            File.should_receive(:exists?).with('config.ru').and_return false
            File.should_receive(:exists?).with(File.join('spec', 'javascripts', 'support', 'jasmine.yml')).and_return true
          end
  
          it 'chooses the jasmine_gem server strategy' do
            server.should_receive(:start_rake_server)
            server.start(:auto, 8888, 'test', 'spec/javascripts')
          end
  
          it 'does wait for the server' do
            server.should_receive(:wait_for_server)
            server.start(:auto, 8888, 'test', 'spec/javascripts')
          end
        end
  
        context 'with a custom spec dir' do
          before do
            File.should_receive(:exists?).with('config.ru').and_return false
            File.should_receive(:exists?).with(File.join('specs', 'support', 'jasmine.yml')).and_return true
          end
  
          it 'chooses the jasmine_gem server strategy' do
            server.should_receive(:start_rake_server)
            server.start(:auto, 8888, 'test', 'specs')
          end
  
          it 'does wait for the server' do
            server.should_receive(:wait_for_server)
            server.start(:auto, 8888, 'test', 'specs')
          end
        end
      end
  
      context 'without any server config files' do
        before do
          File.should_receive(:exists?).with('config.ru').and_return false
          File.should_receive(:exists?).with(File.join('spec', 'javascripts', 'support', 'jasmine.yml')).and_return false
        end
  
        it 'does not start a server' do
          server.should_not_receive(:start_rack_server)
          server.should_not_receive(:start_rake_server)
          server.should_not_receive(:wait_for_server)
          server.start(:auto, 8888, 'test', 'spec/javascripts')
        end
      end
    end
  
    context 'with the :thin strategy' do
      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(:thin, 8888, 'test', 'spec/javascripts')
      end
  
      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(:thin, 8888, 'test', 'spec/javascripts')
      end
  
      it 'starts a :thin rack server' do
        server.should_receive(:start_rack_server).with(8888, 'test', :thin, nil)
        server.start(:thin, 8888, 'test', 'spec/javascripts')
      end
    end
  
    context 'with the :mongrel strategy' do
      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(:mongrel, 8888, 'test', 'spec/javascripts')
      end
  
      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(:mongrel, 8888, 'test', 'spec/javascripts')
      end
  
      it 'starts a :mongrel rack server' do
        server.should_receive(:start_rack_server).with(8888, 'test', :mongrel, nil)
        server.start(:mongrel, 8888, 'test', 'spec/javascripts')
      end
    end
  
    context 'with the :webrick strategy' do
      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(:webrick, 8888, 'test', 'spec/javascripts')
      end
  
      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(:webrick, 8888, 'test', 'spec/javascripts')
      end
  
      it 'starts a :webrick rack server' do
        server.should_receive(:start_rack_server).with(8888, 'test', :webrick, nil)
        server.start(:webrick, 8888, 'test', 'spec/javascripts')
      end
    end
  
    context 'with the :unicorn strategy' do
      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(:unicorn, 8888, 'test', 'spec/javascripts')
      end
  
      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(:unicorn, 8888, 'test', 'spec/javascripts')
      end
  
      it 'starts a :unicorn rack server' do
        server.should_receive(:start_rack_server).with(8888, 'test', :unicorn, nil)
        server.start(:unicorn, 8888, 'test', 'spec/javascripts')
      end
    end
  
    context 'with the :webrick strategy and a custom config.ru' do
      it 'starts a :webrick rack server' do
        server.should_receive(:start_rack_server).with(8888, 'test', :webrick, 'my/cool.ru')
        server.start(:webrick, 8888, 'test', 'spec/javascripts', 'my/cool.ru')
      end
    end
  
    context 'with the :jasmine_gem strategy' do
      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(:jasmine_gem, 8888, 'test', 'spec/javascripts')
      end
  
      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(:jasmine_gem, 8888, 'test', 'spec/javascripts')
      end
  
      it 'starts the :jasmine rake task server' do
        server.should_receive(:start_rake_server).with(8888, 'jasmine')
        server.start(:jasmine_gem, 8888, 'test', 'spec/javascripts')
      end
    end
  
    context 'with a custom rake strategy' do
      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(:start_server, 8888, 'test', 'spec/javascripts')
      end
  
      it 'does wait for the server' do
        server.should_receive(:wait_for_server)
        server.start(:start_server, 8888, 'test', 'spec/javascripts')
      end
  
      it 'starts a custom rake task server' do
        server.should_receive(:start_rake_server).with(8888, 'start_server')
        server.start(:start_server, 8888, 'test', 'spec/javascripts')
      end
    end
  
    context 'with the :none strategy' do
      it 'does not auto detect a server' do
        server.should_not_receive(:detect_server)
        server.start(:none, 8888, 'test', 'spec/javascripts')
      end
  
      it 'does not start a server' do
        server.should_not_receive(:start_rack_server)
        server.should_not_receive(:start_rake_server)
        server.should_not_receive(:wait_for_server)
        server.start(:none, 8888, 'test', 'spec/javascripts')
      end
    end
  end
  
end
