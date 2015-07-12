require 'rails_helper'

RSpec.describe Feeder, type: :model do
  it { expect(FactoryGirl.create(:feeder)).to be_valid }

  describe '.feed_url' do
    it 'is unique' do
      FactoryGirl.create(:feeder, feed_url: 'tryflyer.com/feed.rss')

      expect(FactoryGirl.build(:feeder, feed_url: 'tryflyer.com/feed.rss'))
        .to_not be_valid
    end
  end

  describe '.title' do
    it { expect(FactoryGirl.build(:feeder, title: '')).to_not be_valid }
  end
end
