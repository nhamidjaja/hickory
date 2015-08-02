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
          published_at: Time.zone.local('2014-03-11 11:00:00 +03:00')
        )
      end
      let(:fave_url) do
        FactoryGirl.build(
          :c_user_fave_url,
          c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
          content_url: 'http://example.com/hello',
          id: '123e4567-e89b-12d3-a456-426655440000'
        )
      end
      let(:fave) do
        FactoryGirl.build(
          :c_user_fave,
          c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
          content_url: 'http://example.com/hello',
          id: '123e4567-e89b-12d3-a456-426655440000'
        )
      end

      before do
        expect(Content).to receive(:find_or_initialize_by)
          .with(url: 'http://example.com/hello')
          .and_return(content)
        expect(CUserFaveUrl).to receive(:find_or_initialize_by)
          .and_return(fave_url)
      end

      it 'saves' do
        expect(fave_url).to receive(:save!).with(consistency: :any).once
        expect(CUserFave).to receive(:new).with(
          c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
          id: Cequel.uuid('123e4567-e89b-12d3-a456-426655440000'),
          content_url: 'http://example.com/hello',
          title: 'A headline',
          image_url: 'http://a.com/b.jpg',
          published_at: Time.zone.local('2014-03-11 11:00:00 +03:00')
        ).and_return(fave)
        expect(fave).to receive(:save!).with(consistency: :any)

        worker.perform(
          'de305d54-75b4-431b-adb2-eb6b9e546014',
          'http://example.com/hello?source=xyz'
        )
      end
    end
  end
end
