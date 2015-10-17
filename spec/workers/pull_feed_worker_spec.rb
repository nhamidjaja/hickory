require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe PullFeedWorker do
  describe '.perform' do
    let(:feeder) do
      FactoryGirl.build(
        :feeder,
        id: '55a27bc8-3db3-11e5-b5a1-13c85fe6896f',
        feed_url: 'http://tryflyer.com/feed.rss')
    end

    before do
      allow(Feeder).to receive(:find)
        .with('55a27bc8-3db3-11e5-b5a1-13c85fe6896f')
        .and_return(feeder)
      allow(feeder.top_articles).to receive(:create!)
    end

    subject do
      PullFeedWorker.new
        .perform('55a27bc8-3db3-11e5-b5a1-13c85fe6896f')
    end

    context 'no entries' do
      before do
        double = instance_double(
          'Feedjira::Parser::Atom',
          entries: []
        )
        expect(Feedjira::Feed).to receive(:fetch_and_parse)
          .with('http://tryflyer.com/feed.rss')
          .and_return(double)
      end

      it 'removes existing top articles' do
        feeder.top_articles = [FactoryGirl.build(:top_article)]

        subject

        expect(feeder.top_articles.size).to eq(0)
      end

      it do
        expect(PullFeedWorker).to receive(:perform_in)
          .with(5.minutes, feeder.id.to_s)
          .once

        subject
      end
    end

    context 'one entry' do
      before do
        entry = instance_double(
          'Feedjira::Feed::Entry',
          url: 'http://example.com/article',
          title: 'An article',
          image: 'http://example.com/img.png',
          published: Time.zone.local('2015-01-10 11:11:11 +01:00')
        )
        double = instance_double(
          'Feedjira::Parser::Atom',
          entries: [entry]
        )
        expect(Feedjira::Feed).to receive(:fetch_and_parse)
          .with('http://tryflyer.com/feed.rss')
          .and_return(double)
      end

      it 'creates TopArticle' do
        expect(feeder.top_articles).to receive(:create!)
          .with(
            content_url: 'http://example.com/article',
            title: 'An article',
            image_url: 'http://example.com/img.png',
            published_at: Time.zone.local('2015-01-10 11:11:11 +01:00')
          )

        subject
      end

      it 'creates Content' do
        double = instance_double('Content')
        expect(Content).to receive(:new).with(
          url: 'http://example.com/article',
          title: 'An article',
          image_url: 'http://example.com/img.png',
          published_at: Time.zone.local('2015-01-10 11:11:11 +01:00')
        ).and_return(double)

        expect(double).to receive(:save!).with(consistency: :any)

        subject
      end
    end
  end
end
