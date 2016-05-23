require 'rails_helper'

RSpec.describe UnfollowUserWorker do
  describe '.perform' do
    let(:worker) { UnfollowUserWorker.new }
    let(:user) do
      instance_double(
        'CUser',
        id: Cequel.uuid('4f16d362-a336-4b12-a133-4b8e39be7f8e')
      )
    end
    let(:target) do
      instance_double(
        'CUser',
        id: Cequel.uuid('9d6831a4-39d1-11e5-9128-17e501c711a8')
      )
    end

    before do
      allow(CUser).to receive(:new)
      allow(CUser).to receive(:new)
        .with(id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
        .and_return(user)
      allow(CUser).to receive(:new)
        .with(id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
        .and_return(target)

      allow(user).to receive(:unfollow).with(target)
      allow(target).to receive(:c_user_faves).and_return([])
    end

    subject do
      worker.perform(
        '4f16d362-a336-4b12-a133-4b8e39be7f8e',
        '9d6831a4-39d1-11e5-9128-17e501c711a8'
      )
    end

    it do
      expect(user).to receive(:unfollow).with(target).once

      subject
    end

    it 'records event in GA' do
      expect_any_instance_of(GoogleAnalyticsApi).to receive(:event)
        .with('user_followers',
              '9d6831a4-39d1-11e5-9128-17e501c711a8',
              '4f16d362-a336-4b12-a133-4b8e39be7f8e',
              -1,
              '4f16d362-a336-4b12-a133-4b8e39be7f8e')

      subject
    end

    context 'no faves by target' do
      before do
        allow(target).to receive(:c_user_faves).and_return([])
      end

      it do
        expect { subject }.to_not change(RemoveStoryWorker.jobs, :size)
      end
    end

    context 'one fave by target' do
      before do
        allow(target).to receive(:c_user_faves).and_return(
          [FactoryGirl.build(
            :c_user_fave,
            c_user_id: target.id,
            id: Cequel.uuid('05d08b05-f198-46c7-be00-e5fc848589c1')
          )]
        )
      end

      it do
        expect { subject }.to change(RemoveStoryWorker.jobs, :size).by(1)
      end

      it do
        expect(RemoveStoryWorker).to receive(:perform_async)
          .with('4f16d362-a336-4b12-a133-4b8e39be7f8e',
                '05d08b05-f198-46c7-be00-e5fc848589c1')

        subject
      end
    end

    context 'multiple faves by target' do
      before do
        faves = []

        3.times do
          faves.push(
            FactoryGirl.build(:c_user_fave,
                              c_user_id: target.id)
          )
        end
        allow(target).to receive(:c_user_faves).and_return(faves)
      end

      it do
        expect { subject }.to change(RemoveStoryWorker.jobs, :size).by(3)
      end
    end
  end
end
