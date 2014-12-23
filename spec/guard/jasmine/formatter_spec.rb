require 'guard/jasmine/formatter'

RSpec.describe Guard::Jasmine::Formatter do
  let(:formatter) { Guard::Jasmine::Formatter }

  let(:ui) { Guard::Compat::UI }
  before do
    allow(ui).to receive(:info)
    allow(ui).to receive(:debug)
    allow(ui).to receive(:error)
    allow(ui).to receive(:warning)
    allow(ui).to receive(:color_enabled?).and_return(true)
  end

  describe '.info' do
    it 'shows an info message' do
      expect(ui).to receive(:info).with('Info message',  reset: true)
      formatter.info('Info message',  reset: true)
    end
  end

  describe '.debug' do
    it 'shows a debug message' do
      expect(ui).to receive(:debug).with('Debug message',  reset: true)
      formatter.debug('Debug message',  reset: true)
    end
  end

  describe '.error' do
    it 'shows a colorized error message' do
      expect(ui).to receive(:error).with("\e[0;31mError message\e[0m",  reset: true)
      formatter.error('Error message',  reset: true)
    end
  end

  describe '.spec_failed' do
    it 'shows a colorized spec failed message' do
      expect(ui).to receive(:info).with("\e[0;31mSpec failed message\e[0m",  reset: true)
      formatter.spec_failed('Spec failed message',  reset: true)
    end
  end

  describe '.success' do
    it 'shows a colorized success message' do
      expect(ui).to receive(:info).with("\e[0;32mSuccess message\e[0m",  reset: true)
      formatter.success('Success message',  reset: true)
    end
  end

  describe '.notify' do
    it 'shows an info message' do
      expect(ui).to receive(:notify).with('Notify message',  image: :failed)
      formatter.notify('Notify message',  image: :failed)
    end
  end
end
