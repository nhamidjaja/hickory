require 'rails_helper'

RSpec.describe TopArticle, type: :model do
  it { expect(FactoryGirl.build(:top_article)).to be_valid }

  describe '.content_url' do
    it do
      expect(FactoryGirl.build(:top_article,
                               content_url: '')).to_not be_valid
    end
  end

  describe '.title' do
    it { expect(FactoryGirl.build(:top_article, title: '')).to_not be_valid }
  end

  describe '#since' do
    context 'unspecified last_published_at' do
      subject { TopArticle.since(nil) }

      it 'is sorted by descending published_at' do
        relation = instance_double('ActiveRecord::Relation')

        expect(TopArticle).to receive(:all).and_return(relation)
        expect(relation).to receive(:order).with(
          published_at: :desc)

        subject
      end
    end

    context 'with last_published_at' do
      # 1437408070 => 2015-07-20 19:01:10 +03:00
      subject { TopArticle.since(1_437_408_070) }

      it 'is sorted by descending published_at' do
        relation = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')

        expect(TopArticle).to receive(:all).and_return(relation)
        expect(relation).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:where).with(
          'published_at < ?',
          Time.zone.parse('2015-07-20 19:01:10 +03:00'))

        subject
      end
    end
  end
end
