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
    end

    it 'increments views by 1' do
      expect(metal).to receive(:where)
        .with(c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
              id: Cequel.uuid('123e4567-e89b-12d3-a456-426655440000'))
      expect(metal).to receive(:increment).with(views: 1)

      worker.perform('de305d54-75b4-431b-adb2-eb6b9e546014',
                     '123e4567-e89b-12d3-a456-426655440000')
    end
  end
end
