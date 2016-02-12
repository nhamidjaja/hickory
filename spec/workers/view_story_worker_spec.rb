require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ViewStoryWorker do
  describe '.perform' do
    let(:worker) { ViewStoryWorker.new }
    let(:metal) { instance_double('Cequel::Metal::DataSet') }

    before do
      allow(Cequel::Metal::DataSet).to receive(:new).and_return(metal)
      allow(metal).to receive(:consistency).and_return(metal)
      allow(metal).to receive(:where).and_return(metal)
      allow(metal).to receive(:increment)
    end

    it 'increments views by 1' do
      expect(metal).to receive(:where)
        .with(c_user_id: 'user', id: 'story')
      expect(metal).to receive(:increment).with(views: 1)

      worker.perform('user', 'story')
    end
  end
end
