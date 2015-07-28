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

  describe '.image_url' do
    it do
      expect(FactoryGirl.build(:top_article,
                               image_url: '')).to_not be_valid
    end
  end

  describe '.latest_top' do
    context 'default parameters' do
      it do
        relation = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')

        expect(TopArticle).to receive(:all).and_return(relation)
        expect(relation).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:take).with(50)

        TopArticle.latest_top(nil, nil)
      end
    end

    context 'with last_published_at' do
      it do
        relation = instance_double('ActiveRecord::Relation')
        where = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')

        expect(TopArticle).to receive(:all).and_return(relation)
        expect(relation).to receive(:where).with(
          'published_at <= ?', Time.zone.local(2015, 7, 15, 19, 1, 10, '+00:00')
        ).and_return(where)
        expect(where).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:take).with(50)

        # 1436986870 => 2015-07-15 19:01:10
        TopArticle.latest_top(1_436_986_870, nil)
      end
    end

    context 'with limit' do
      it 'takes limit' do
        relation = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')

        expect(TopArticle).to receive(:all).and_return(relation)
        expect(relation).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:take).with(17)

        TopArticle.latest_top(nil, 17)
      end
    end

    context 'with last_published_at and limit' do
      it 'takes limit' do
        relation = instance_double('ActiveRecord::Relation')
        where = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')

        expect(TopArticle).to receive(:all).and_return(relation)
        expect(relation).to receive(:where).with(
          'published_at <= ?', Time.zone.local(2015, 7, 15, 19, 1, 10, '+00:00')
        ).and_return(where)
        expect(where).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:take).with(3)

        # 1436986870 => 2015-07-15 19:01:10
        TopArticle.latest_top(1_436_986_870, 3)
      end
    end
  end
end
