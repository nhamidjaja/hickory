# frozen_string_literal: true
require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe BroadcastFaveWorker do
  describe '.perform' do
    let(:worker) { BroadcastFaveWorker.new }
    let(:fcm) { instance_double('FCM') }

    before do
      allow(FCM).to receive(:new)
        .and_return(fcm)
    end

    it 'sends notification' do
      expect(fcm).to receive(:send)
        .with(['token'],
              notification: {
                icon: 'ic_notify',
                color: '#FF9800',
                title: '@username',
                body: 'Some News Headline'
              })
        .and_return(response: 'success',
                    canonical_ids: [],
                    not_registered_ids: [])

      worker.perform(
        'token',
        'username',
        'Some News Headline'
      )
    end

    it 'deletes unregistered tokens' do
      allow(fcm).to receive(:send)
        .and_return(response: 'success',
                    canonical_ids: [],
                    not_registered_ids: ['token'])

      double = instance_double('ActiveRecord::Relation')
      expect(Gcm).to receive(:where)
        .with(registration_token: 'token')
        .and_return(double)
      expect(double).to receive(:destroy_all)

      worker.perform(
        'token',
        'username',
        'Some News Headline'
      )
    end

    it 'updates token' do
      allow(fcm).to receive(:send)
        .and_return(response: 'success',
                    canonical_ids: ['canon'],
                    not_registered_ids: [])

      gcm = instance_double('Gcm')
      expect(Gcm).to receive(:find)
        .with('token')
        .and_return(gcm)

      expect(gcm).to receive(:update_attributes!)
        .with(registration_token: 'canon')

      worker.perform(
        'token',
        'username',
        'Some News Headline'
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
          'username',
          'Some News Headline'
        )
      end.to raise_error(RuntimeError, 'Server is temporarily unavailable.')
    end

    it 'tracks event' do
      allow(fcm).to receive(:send)
        .and_return(response: 'success',
                    canonical_ids: [],
                    not_registered_ids: [])

      expect_any_instance_of(GoogleAnalyticsApi).to receive(:event)
        .with('cloud_messaging',
              'broadcast_fave',
              '@username',
              0,
              'Some News Headline')

      worker.perform(
        'token',
        'username',
        'Some News Headline'
      )
    end
  end
end
