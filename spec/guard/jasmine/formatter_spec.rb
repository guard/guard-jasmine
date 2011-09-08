require 'spec_helper'

describe Guard::Jasmine::Formatter do

  let(:formatter) { Guard::Jasmine::Formatter }
  let(:ui) { Guard::UI }
  let(:notifier) { Guard::Notifier }

  describe '.info' do
    it 'shows an info message' do
      ui.should_receive(:info).with('Info message', { :reset => true })
      formatter.info('Info message', { :reset => true })
    end
  end

  describe '.debug' do
    it 'shows a debug message' do
      ui.should_receive(:debug).with('Debug message', { :reset => true })
      formatter.debug('Debug message', { :reset => true })
    end
  end

  describe '.error' do
    it 'shows a colorized error message' do
      ui.should_receive(:error).with("\e[0;31mError message\e[0m", { :reset => true })
      formatter.error('Error message', { :reset => true })
    end
  end

  describe '.spec_error' do
    it 'shows a colorized spec error message' do
      formatter.should_receive(:puts).with("\e[0;31mSpec error message\e[0m")
      formatter.spec_error('Spec error message')
    end
  end

  describe '.success' do
    it 'shows a colorized success message' do
      ui.should_receive(:info).with("\e[0;32mSuccess message\e[0m", { :reset => true })
      formatter.success('Success message', { :reset => true })
    end
  end

  describe '.notify' do
    it 'shows an info message' do
      notifier.should_receive(:notify).with('Notify message', { :image => :failed })
      formatter.notify('Notify message', { :image => :failed })
    end
  end
end
