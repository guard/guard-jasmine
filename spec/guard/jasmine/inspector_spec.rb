RSpec.describe Guard::Jasmine::Inspector do
  before do
    allow(File).to receive(:exists?) do |file|
      ['spec/javascripts/a_spec.js.coffee', 'spec/javascripts/b_spec.js', 'c_spec.coffee'].include?(file)
    end
  end

  subject { Guard::Jasmine::Inspector }

  let(:options) { { spec_dir: 'spec/javascripts' } }

  describe 'clean' do
    it 'allows the Jasmine spec dir' do
      expect(subject.clean(['spec/javascripts', 'spec/javascripts/a.js.coffee'], options)).to eql(['spec/javascripts'])
    end

    it 'removes duplicate files' do
      expect(subject.clean(['spec/javascripts/a_spec.js.coffee', 'spec/javascripts/a_spec.js.coffee'], options)).to eql ['spec/javascripts/a_spec.js.coffee']
    end

    it 'remove nil files' do
      expect(subject.clean(['spec/javascripts/a_spec.js.coffee', nil], options)).to eql ['spec/javascripts/a_spec.js.coffee']
    end

    it 'removes files that are no javascript specs' do
      expect(subject.clean(['spec/javascripts/a_spec.js.coffee',
                     'spec/javascripts/b_spec.js',
                     'app/assets/javascripts/a.js.coffee',
                     'b.txt',
                     'c_spec.coffee'], options)).to eql ['spec/javascripts/a_spec.js.coffee', 'spec/javascripts/b_spec.js', 'c_spec.coffee']
    end

  end
end
