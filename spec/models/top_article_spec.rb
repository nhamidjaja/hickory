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
    context 'default parameter' do
      it do
        relation = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')
        expect(TopArticle).to receive(:all).and_return(relation)
        expect(relation).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:take).with(50)

        TopArticle.latest_top
      end
    end

    context 'custom last_published_at parameter' do
      it do
        relation = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')
        expect(TopArticle).to receive(:where).with(
          'published_at <= ?', Time.zone.at(
                                 '2015-07-15 19:01:10'.in_time_zone.to_i)
        ).and_return(relation)
        expect(relation).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:take).with(50)

        TopArticle.latest_top('2015-07-15 19:01:10'.in_time_zone.to_i)
      end
    end

    context 'custom limit parameter' do
      it do
        relation = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')
        expect(TopArticle).to receive(:where).with(
          'published_at <= ?', Time.zone.at(
                                 '2015-07-15 19:01:10'.in_time_zone.to_i)
        ).and_return(relation)
        expect(relation).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:take).with(20)

        TopArticle.latest_top('2015-07-15 19:01:10'.in_time_zone.to_i, 20)
      end
    end

    context 'if limit nil' do
      it do
        relation = instance_double('ActiveRecord::Relation')
        order = instance_double('ActiveRecord::Relation')
        expect(TopArticle).to receive(:where).with(
          'published_at <= ?', Time.zone.at(
                                 '2015-07-15 19:01:10'.in_time_zone.to_i)
        ).and_return(relation)
        expect(relation).to receive(:order).with(
          published_at: :desc).and_return(order)
        expect(order).to receive(:take).with(50)

        TopArticle.latest_top('2015-07-15 19:01:10'.in_time_zone.to_i, nil)
      end
    end
  end
end
