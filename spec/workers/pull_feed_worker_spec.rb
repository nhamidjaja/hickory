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

      it do
        expect(MasterFeed).to receive(:create).exactly(0).times

        subject
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

      it do
        expect(MasterFeed).to receive(:create).exactly(1).times

        subject
      end
    end
  end
end
