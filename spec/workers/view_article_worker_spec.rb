require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ViewArticleWorker do
  describe '.perform' do
    let(:worker) { ViewArticleWorker.new }
    let(:metal) { instance_double('Cequel::Metal::DataSet') }

    before do
      allow(Cequel::Metal::DataSet).to receive(:new).and_return(metal)
      allow(metal).to receive(:consistency).and_return(metal)
      allow(metal).to receive(:where).and_return(metal)
      allow(metal).to receive(:increment)

      allow_any_instance_of(GoogleAnalyticsApi).to receive(:event)
    end

    it 'increments views by 1' do
      expect(metal).to receive(:where)
        .with(c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
              id: Cequel.uuid('123e4567-e89b-12d3-a456-426655440000'))
      expect(metal).to receive(:increment).with(views: 1)

      worker.perform('6e927505-dc1f-4b01-9490-a0d2523b904a',
                     'de305d54-75b4-431b-adb2-eb6b9e546014',
                     '123e4567-e89b-12d3-a456-426655440000',
                     'http://a.com')
    end

    it 'records event in GA' do
      expect_any_instance_of(GoogleAnalyticsApi).to receive(:event)
        .with('article',
              'de305d54-75b4-431b-adb2-eb6b9e546014',
              'de305d54-75b4-431b-adb2-eb6b9e546014/'\
              '123e4567-e89b-12d3-a456-426655440000/'\
              'http://a.com',
              0,
              '6e927505-dc1f-4b01-9490-a0d2523b904a')

      worker.perform('6e927505-dc1f-4b01-9490-a0d2523b904a',
                     'de305d54-75b4-431b-adb2-eb6b9e546014',
                     '123e4567-e89b-12d3-a456-426655440000',
                     'http://a.com')
    end

    context 'without attributions' do
      it 'does not increment view' do
        expect(metal).to_not receive(:increment)

        worker.perform(nil, nil, nil, nil)
      end
    end
  end
end
