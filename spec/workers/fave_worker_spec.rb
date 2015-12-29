require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe FaveWorker do
  describe '.perform' do
    context 'valid' do
      let(:worker) { FaveWorker.new }
      let(:content) do
        FactoryGirl.build(
          :content,
          url: 'http://example.com/hello',
          title: 'A headline',
          image_url: 'http://a.com/b.jpg',
          published_at: Time.zone.parse('2014-03-11 11:00:00 +03:00').utc
        )
      end
      let(:c_user) do
        FactoryGirl.build(
          :c_user,
          id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014')
        )
      end
      let(:fave_id) { Cequel.uuid(Time.zone.now.utc) }
      let(:faved_at) do
        Time.zone.parse('2015-08-18 05:31:28 UTC').utc
      end

      subject do
        worker.perform(
          'de305d54-75b4-431b-adb2-eb6b9e546014',
          'http://example.com/hello?source=xyz',
          '2015-08-18 05:31:28 UTC'
        )
      end

      before do
        allow(Content).to receive(:find_or_initialize_by)
          .and_return(content)
        allow(CUser).to receive(:new)
          .with(id: 'de305d54-75b4-431b-adb2-eb6b9e546014')
          .and_return(c_user)

        fave = instance_double(
          'CUserFave',
          c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
          id: fave_id,
          content_url: content.url,
          title: content.title,
          image_url: content.image_url,
          published_at: content.published_at,
          faved_at: faved_at
        )
        allow(c_user).to receive(:fave).and_return(fave)
      end

      it 'finds with canon url' do
        expect(Content).to receive(:find_or_initialize_by)
          .with(url: 'http://example.com/hello')

        subject
      end

      it 'faves' do
        expect(c_user).to receive(:fave)
          .with(content, faved_at)

        subject
      end

      context 'no followers' do
        before do
          allow(c_user).to receive(:followers)
            .and_return([])
        end

        it do
          expect { subject }.to_not change(StoryWorker.jobs, :size)
        end
      end

      context 'one follower' do
        before do
          followers = [instance_double(
            'Follower',
            c_user: c_user,
            id: Cequel.uuid('123e4567-e89b-12d3-a456-426655440000'))]
          allow(c_user).to receive(:followers).and_return(followers)
        end

        it do
          expect { subject }.to change(StoryWorker.jobs, :size).by(1)
        end

        it do
          expect(StoryWorker).to receive(:perform_async)
            .with('123e4567-e89b-12d3-a456-426655440000',
                  'de305d54-75b4-431b-adb2-eb6b9e546014',
                  fave_id.to_s,
                  'http://example.com/hello',
                  'A headline',
                  'http://a.com/b.jpg',
                  '2014-03-11 08:00:00 UTC',
                  '2015-08-18 05:31:28 UTC'
                 )

          subject
        end
      end

      context 'many followers' do
        before do
          followers = []
          5.times do
            followers.push(
              instance_double('Follower',
                              c_user: c_user,
                              id: Cequel.uuid))
          end
          allow(c_user).to receive(:followers).and_return(followers)
        end

        it do
          expect { subject }.to change(StoryWorker.jobs, :size).by(5)
        end
      end

      describe 'manual override' do
        it do
          expect_any_instance_of(Content).to receive(:save!).and_return(content)
          worker.perform(
            'de305d54-75b4-431b-adb2-eb6b9e546014',
            'http://example.com/hello?source=xyz',
            '2015-08-18 05:31:28 UTC',
            'some title',
            'an image',
            '2015-04-16 03:11:28 UTC'
          )
        end
      end
    end
  end
end
