# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FollowUserWorker do
  describe '.perform' do
    let(:worker) { FollowUserWorker.new }
    let(:user) do
      FactoryGirl.build(:user, id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:c_user) do
      instance_double('CUser', id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end

    let(:target) do
      FactoryGirl.build(:user, id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end
    let(:c_target) do
      instance_double('CUser', id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end

    before do
      allow(User).to receive(:find)
        .with('4f16d362-a336-4b12-a133-4b8e39be7f8e')
        .and_return(user)
      allow(User).to receive(:find)
        .with('9d6831a4-39d1-11e5-9128-17e501c711a8')
        .and_return(target)

      allow(user).to receive(:in_cassandra)
        .and_return(c_user)
      allow(target).to receive(:in_cassandra)
        .and_return(c_target)

      allow(c_user).to receive(:follow).with(c_target)
      allow(c_target).to receive(:c_user_faves).and_return([])
      allow(target).to receive(:gcms).and_return([])
    end

    subject do
      worker.perform(
        '4f16d362-a336-4b12-a133-4b8e39be7f8e',
        '9d6831a4-39d1-11e5-9128-17e501c711a8'
      )
    end

    it do
      expect(c_user).to receive(:follow).with(c_target).once
      subject
    end

    it 'records event in GA' do
      expect_any_instance_of(GoogleAnalyticsApi).to receive(:event)
        .with('user_followers',
              '9d6831a4-39d1-11e5-9128-17e501c711a8',
              '4f16d362-a336-4b12-a133-4b8e39be7f8e',
              1,
              '4f16d362-a336-4b12-a133-4b8e39be7f8e')

      subject
    end

    describe 'forward faves' do
      context 'no faves' do
        before do
          allow(c_target).to receive(:c_user_faves).and_return([])
        end

        it do
          expect { subject }.to_not change(StoryWorker.jobs, :size)
        end
      end

      context 'one fave' do
        before do
          allow(c_target).to receive(:c_user_faves).and_return(
            [FactoryGirl.build(
              :c_user_fave,
              c_user_id: user.id,
              id: Cequel.uuid('05d08b05-f198-46c7-be00-e5fc848589c1'),
              content_url: 'http://example.com/hello',
              title: 'A headline',
              image_url: 'http://a.com/b.jpg',
              published_at: '2014-03-11 08:00:00 UTC',
              faved_at: '2015-08-18 05:31:28 UTC'
            )]
          )
        end

        it do
          expect { subject }.to change(StoryWorker.jobs, :size).by(1)
        end

        it do
          expect(StoryWorker).to receive(:perform_async)
            .with('4f16d362-a336-4b12-a133-4b8e39be7f8e',
                  '9d6831a4-39d1-11e5-9128-17e501c711a8',
                  '05d08b05-f198-46c7-be00-e5fc848589c1',
                  'http://example.com/hello',
                  'A headline',
                  'http://a.com/b.jpg',
                  '2014-03-11 08:00:00 UTC',
                  '2015-08-18 05:31:28 UTC')

          subject
        end
      end

      context 'multiple faves' do
        before do
          faves = []

          3.times do
            faves.push(
              FactoryGirl.build(:c_user_fave,
                                c_user_id: user.id)
            )
          end
          allow(c_target).to receive(:c_user_faves).and_return(faves)
        end

        it do
          expect { subject }.to change(StoryWorker.jobs, :size).by(3)
        end
      end
    end

    describe 'notify target' do
      context 'no devices' do
        before do
          allow(target).to receive(:gcms).and_return([])
        end

        it do
          expect { subject }.to_not change(NotifyNewFollowerWorker.jobs, :size)
        end
      end

      context 'one device' do
        let(:gcm) { FactoryGirl.build(:gcm, registration_token: 'token') }
        before do
          allow(target).to receive(:gcms).and_return([gcm])
        end

        it do
          expect { subject }.to change(NotifyNewFollowerWorker.jobs, :size)
            .by(1)
        end

        it do
          expect(NotifyNewFollowerWorker).to receive(:perform_async)
            .with('token',
                  user.id.to_s,
                  user.username)

          subject
        end
      end

      context 'multiple devices' do
        before do
          gcms = FactoryGirl.build_list(:gcm, 3)
          allow(target).to receive(:gcms).and_return(gcms)
        end

        it do
          expect { subject }.to change(NotifyNewFollowerWorker.jobs, :size)
            .by(3)
        end
      end
    end
  end
end
