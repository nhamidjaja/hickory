# frozen_string_literal: true
require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe BroadcastUserStoryWorker do
  describe '.perform' do
    let(:worker) { BroadcastUserStoryWorker.new }
    let(:user) do
      FactoryGirl.build(
        :user,
        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
        current_sign_in_at: nil
      )
    end
    let(:faver) do
      FactoryGirl.build(
        :user,
        id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
        username: 'faver'
      )
    end
    let(:c_user) { instance_double('CUser') }
    let(:story) do
      FactoryGirl.build(
        :story,
        id: 'f8acce33-805d-4d40-995c-4db4a0dc656e',
        content_url: 'http://example.com/article',
        title: 'Some Headline',
        image_url: 'http://example.com/image.jpg'
      )
    end
    let(:stories) { [story] }

    before do
      allow(User).to receive(:find)
        .with(user.id.to_s)
        .and_return(user)
      allow(user).to receive(:in_cassandra)
        .and_return(c_user)
      allow(story).to receive(:faver)
        .and_return(faver)

      allow(c_user).to receive(:stories)
        .and_return([])
    end

    context 'story exists' do
      before do
        allow(c_user).to receive(:stories)
          .and_return(stories)
      end

      it 'queues notification' do
        expect(BroadcastFaveWorker).to receive(:perform_async)
          .with('token',
                'de305d54-75b4-431b-adb2-eb6b9e546014',
                'faver',
                'f8acce33-805d-4d40-995c-4db4a0dc656e',
                'http://example.com/article',
                'Some Headline',
                'http://example.com/image.jpg')

        worker.perform(
          user.id.to_s,
          'token'
        )
      end

      context 'user is active' do
        before do
          allow(user).to receive(:active_recently?).and_return(true)
        end

        it 'does not queue notification' do
          expect(BroadcastFaveWorker).to_not receive(:perform_async)

          worker.perform(
            user.id.to_s,
            'token'
          )
        end
      end
    end

    context 'no story' do
      it 'does not queue notification' do
        expect(BroadcastFaveWorker).to_not receive(:perform_async)

        worker.perform(
          user.id.to_s,
          'token'
        )
      end
    end
  end
end
