require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe PullFeedWorker do
  describe '.perform' do
    let(:feeder) do
      FactoryGirl.create(:feeder,
                         feed_url: 'http://tryflyer.com/feed.rss')
    end
    subject { PullFeedWorker.new.perform(feeder.id.to_s) }

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
        FactoryGirl.create(:top_article, feeder: feeder)

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
        entry = instance_double('Feedjira::Feed::Entry',
                                url: 'http://example.com/article',
                                title: 'An article',
                                image: 'http://example.com/img.png',
                                published: Time.zone.now
                               )
        double = instance_double(
          'Feedjira::Parser::Atom',
          entries: [entry]
        )
        expect(Feedjira::Feed).to receive(:fetch_and_parse)
          .with('http://tryflyer.com/feed.rss')
          .and_return(double)
      end

      it 'creates top article' do
        subject

        expect(feeder.top_articles.size).to eq(1)
      end

      describe 'attributes' do
        before { subject }
        let(:article) { feeder.top_articles.first }

        it { expect(article.content_url).to eq('example.com/article') }
        it { expect(article.title).to eq('An article') }
        it { expect(article.image_url).to eq('http://example.com/img.png') }
      end
    end
  end
end
