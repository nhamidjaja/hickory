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
end
