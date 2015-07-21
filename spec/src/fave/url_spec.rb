require 'rails_helper'

RSpec.describe Fave::Url do
  describe '#canon' do
    it 'removes query and fragment' do
      url = Fave::Url.new('http://example.com/some-path/?a=\11\15#fragment')

      expect(url.canon).to eq('http://example.com/some-path')
    end

    it 'removes trailing slash' do
      url = Fave::Url.new('http://example.com/a-path/')

      expect(url.canon).to eq('http://example.com/a-path')
    end

    it 'replaces protocol' do
      url = Fave::Url.new('https://example.com/a-path')

      expect(url.canon).to eq('http://example.com/a-path')
    end
  end
end
