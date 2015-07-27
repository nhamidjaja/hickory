require 'rails_helper'

RSpec.describe Feeder, type: :model do
  it { expect(FactoryGirl.create(:feeder)).to be_valid }

  describe '.feed_url' do
    it { expect(FactoryGirl.build(:feeder, feed_url: '')).to_not be_valid }

    it 'is unique' do
      FactoryGirl.create(:feeder, feed_url: 'tryflyer.com/feed.rss')

      expect(FactoryGirl.build(:feeder, feed_url: 'tryflyer.com/feed.rss'))
        .to_not be_valid
    end
  end

  describe '.title' do
    it { expect(FactoryGirl.build(:feeder, title: '')).to_not be_valid }
  end

  describe '.request_top_article' do
    context 'return' do
      it '0 data' do
        expect(Feeder.top_articles.size).to eq(0)
      end

      it '1 data' do
        top = FactoryGirl.create(:top_article)

        expect(Feeder.top_articles.size).to eq(1)
        expect(Feeder.top_articles.first.content_url).to eq(top.content_url)
      end
    end
  end
end
