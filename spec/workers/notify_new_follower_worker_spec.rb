# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NotifyNewFollowerWorker do
  describe '.perform' do
    let(:worker) { NotifyNewFollowerWorker.new }
    let(:fcm) { instance_double('FCM') }

    before do
      allow(FCM).to receive(:new)
        .and_return(fcm)
      allow(fcm).to receive(:send)
        .and_return(response: 'success',
                    canonical_ids: [],
                    not_registered_ids: [])
    end

    it 'sends a notification' do
      expect(fcm).to receive(:send)
        .with(['token'],
              data: {
                type: 'new_follower',
                user_id: 'target-id',
                user_username: 'target-username'
              })
        .and_return(response: 'success',
                    canonical_ids: [],
                    not_registered_ids: [])

      worker.perform(
        'token',
        'target-id',
        'target-username'
      )
    end

    it 'upkeeps token' do
      expect(worker).to receive(:token_upkeep)

      worker.perform(
        'token',
        'target-id',
        'target-username'
      )
    end

    it 'fails on error' do
      allow(fcm).to receive(:send)
        .and_return(response: 'Server is temporarily unavailable.',
                    canonical_ids: [],
                    not_registered_ids: [])

      expect do
        worker.perform(
          'token',
          'target-id',
          'target-username'
        )
      end.to raise_error(RuntimeError, 'Server is temporarily unavailable.')
    end
  end
end
