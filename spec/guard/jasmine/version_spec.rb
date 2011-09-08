require 'spec_helper'

describe Guard::JasmineVersion do
  describe 'VERSION' do
    it 'defines the version' do
      Guard::JasmineVersion::VERSION.should match /\d+.\d+.\d+/
    end
  end
end
