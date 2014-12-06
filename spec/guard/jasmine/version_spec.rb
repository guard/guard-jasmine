RSpec.describe Guard::JasmineVersion do
  describe 'VERSION' do
    it 'defines the version' do
      expect(Guard::JasmineVersion::VERSION).to match /\d+.\d+.\d+/
    end
  end
end
