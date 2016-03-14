require 'rails_helper'

RSpec.describe GoogleAnalyticsApi do
  describe '.event' do
    before do
      allow(Typhoeus).to receive(:post)
    end

    it do
      expect(Typhoeus).to receive(:post)
        .with('www.google-analytics.com/collect',
              params: {
                v: 1,
                tid: Figaro.env.google_analytics_tracking_id,
                cid: 'client',
                uid: 'user',
                t: 'event',
                ec: 'category',
                ea: 'action',
                el: 'label',
                ev: 1
              },
              timeout: 5)

      GoogleAnalyticsApi.new.event('category',
                                   'action', 'label', 1, 'user', 'client')
    end

    it 'params compacted' do
      expect(Typhoeus).to receive(:post)
        .with('www.google-analytics.com/collect',
              params: {
                v: 1,
                tid: Figaro.env.google_analytics_tracking_id,
                cid: 'webapp',
                t: 'event',
                ec: 'category',
                ea: 'action'
              },
              timeout: 5)

      GoogleAnalyticsApi.new.event('category', 'action')
    end
  end
end
