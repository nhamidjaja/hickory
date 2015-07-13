require 'rails_helper'

RSpec.describe MasterFeed, type: :model do
  it { expect(FactoryGirl.create(:master_feed)).to be_valid }

  describe '.content_url' do
    it 'is canonicalized' do
      expect(FactoryGirl.create(:master_feed,
                                content_url: 'http://example.com/abc.html?x=y')
        .content_url)
        .to eq('example.com/abc.html')
    end
  end
end
