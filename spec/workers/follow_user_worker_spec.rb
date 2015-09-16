require 'rails_helper'

RSpec.describe FollowUserWorker do
  describe '.perform' do
    let(:worker) { FollowUserWorker.new }
    let(:user) do
      instance_double('CUser', id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:target) do
      instance_double('CUser', id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end

    before do
      allow(CUser).to receive(:new)
      allow(CUser).to receive(:new)
        .with(id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
        .and_return(user)
      allow(CUser).to receive(:new)
        .with(id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
        .and_return(target)

      allow(user).to receive(:follow).with(target)
      allow(target).to receive(:c_user_faves).and_return([])
    end

    subject do
      worker.perform(
        '4f16d362-a336-4b12-a133-4b8e39be7f8e',
        '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end

    it do
      expect(user).to receive(:follow).with(target).once
      subject
    end

    context 'no faves by target' do
      before do
        allow(target).to receive(:c_user_faves).and_return([])
      end

      it do
        expect { subject }.to_not change(FollowingFeedWorker.jobs, :size)
      end
    end

    context 'one fave by target' do
      before do
        allow(target).to receive(:c_user_faves).and_return(
          [FactoryGirl.build(
            :c_user_fave,
            c_user_id: user.id,
            id: Cequel.uuid('05d08b05-f198-46c7-be00-e5fc848589c1'),
            content_url: 'http://example.com/hello',
            title: 'A headline',
            image_url: 'http://a.com/b.jpg',
            published_at: '2014-03-11 08:00:00 UTC',
            faved_at: '2015-08-18 05:31:28 UTC'
          )])
      end

      it do
        expect { subject }.to change(FollowingFeedWorker.jobs, :size).by(1)
      end

      it do
        expect(FollowingFeedWorker).to receive(:perform_async)
          .with('4f16d362-a336-4b12-a133-4b8e39be7f8e',
                '9d6831a4-39d1-11e5-9128-17e501c711a8',
                '05d08b05-f198-46c7-be00-e5fc848589c1',
                'http://example.com/hello',
                'A headline',
                'http://a.com/b.jpg',
                '2014-03-11 08:00:00 UTC',
                '2015-08-18 05:31:28 UTC'
               )

        subject
      end
    end

    context 'multiple faves by target' do
      before do
        faves = []

        3.times do
          faves.push(
            FactoryGirl.build(:c_user_fave,
                              c_user_id: user.id)
          )
        end
        allow(target).to receive(:c_user_faves).and_return(faves)
      end

      it do
        expect { subject }.to change(FollowingFeedWorker.jobs, :size).by(3)
      end
    end
  end
end
