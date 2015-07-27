require 'rails_helper'

RSpec.describe TopArticle, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:top_article)).to be_valid
  end

  describe '.content_url' do
    it do
      expect(FactoryGirl.build(:top_article,
                               content_url: '')).to_not be_valid
    end
  end

  describe '.feeder_id' do
    it do
      expect(FactoryGirl.build(:top_article,
                               feeder_id: '')).to_not be_valid
    end
  end

  describe '.title' do
    it { expect(FactoryGirl.build(:top_article, title: '')).to_not be_valid }
  end

  describe '.image_url' do
    it do
      expect(FactoryGirl.build(:top_article,
                               image_url: '')).to_not be_valid
    end
  end

  describe '.latest_top' do
    let(:top_article1) { FactoryGirl.create(:top_article) }
    let(:top_article2) do
      feed = FactoryGirl.create(:feeder, feed_url: 'http://detik.com')
      FactoryGirl.create(:top_article, feeder: feed)
    end

    before do
      top_article1
      top_article2
    end

    context 'limit' do
      it '1 data' do
        expect(TopArticle.latest_top(1, nil).size).to eq(1)
      end

      it '2 data' do
        expect(TopArticle.latest_top(2, nil).size).to eq(2)
      end
    end

    context 'last_published_at' do
      it '0 data' do
        expect(TopArticle.latest_top(nil,
                                     '2015-07-15 19:01:10'.in_time_zone.to_i
                                    ).size).to eq(0)
      end

      it '2 data' do
        expect(TopArticle.latest_top(nil,
                                     top_article1.published_at.in_time_zone.to_i
                                    ).size).to eq(2)
      end
    end
  end
end
