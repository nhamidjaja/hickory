require 'rails_helper'

RSpec.describe Fave::Uri do
  describe '#canon' do
    it 'removes query and fragment' do
      uri = Fave::Uri.new('https://example.com/some-path/?a=\11\15#fragment')

      expect(uri.canon).to eq('example.com/some-path')
    end

    it 'removes trailing slash' do
      uri = Fave::Uri.new('https://example.com/a-path/')

      expect(uri.canon).to eq('example.com/a-path')
    end
  end
end
