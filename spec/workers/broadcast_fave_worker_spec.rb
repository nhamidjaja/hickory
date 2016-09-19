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

    subject do
      worker.perform(
        'token',
        'de305d54-75b4-431b-adb2-eb6b9e546014',
        'someuser',
        '4f16d362-a336-4b12-a133-4b8e39be7f8e',
        'http://example.com/article',
        'Some News Headline',
        'http://example.com/a.jpg'
      )
    end

    it 'sends notification' do
      expect(fcm).to receive(:send)
        .with(['token'],
              data: {
                type: 'story',
                faver_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                faver_username: 'someuser',
                story_id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
                story_url: 'http://example.com/article',
                story_title: 'Some News Headline',
                story_image_url: 'http://example.com/a.jpg'
              })
        .and_return(response: 'success',
                    canonical_ids: [],
                    not_registered_ids: [])

      subject
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

      subject
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

      subject
    end

    it 'fails on error' do
      allow(fcm).to receive(:send)
        .and_return(response: 'Server is temporarily unavailable.',
                    canonical_ids: [],
                    not_registered_ids: [])

      expect do
        subject
      end.to raise_error(RuntimeError, 'Server is temporarily unavailable.')
    end

    # it 'tracks event' do
    #   allow(fcm).to receive(:send)
    #     .and_return(response: 'success',
    #                 canonical_ids: [],
    #                 not_registered_ids: [])

    #   expect_any_instance_of(GoogleAnalyticsApi).to receive(:event)
    #     .with('cloud_messaging',
    #           'broadcast_fave',
    #           '@username',
    #           0,
    #           'Some News Headline')

    #   subject
    # end
  end
end
