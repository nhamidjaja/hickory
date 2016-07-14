# frozen_string_literal: true
require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe BroadcastUserStoryWorker do
  describe '.perform' do
    let(:worker) { BroadcastUserStoryWorker.new }
    let(:user) do
      FactoryGirl.build(
        :user,
        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e'
      )
    end
    let(:faver) { FactoryGirl.build(:user, username: 'faver') }
    let(:c_user) { instance_double('CUser') }
    let(:story) do
      FactoryGirl.build(
        :story,
        title: 'Some Headline'
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
          .with('token', 'faver', 'Some Headline')

        worker.perform(
          user.id.to_s,
          'token'
        )
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
