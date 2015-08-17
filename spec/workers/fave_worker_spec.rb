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
      let(:c_user) do
        FactoryGirl.build(
          :c_user,
          id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014')
        )
      end

      before do
        expect(Content).to receive(:find_or_initialize_by)
          .with(url: 'http://example.com/hello')
          .and_return(content)
        expect(CUser).to receive(:new)
          .with(id: 'de305d54-75b4-431b-adb2-eb6b9e546014')
          .and_return(c_user)
      end

      it 'faves' do
        expect(c_user).to receive(:fave).with(content)

        worker.perform(
          'de305d54-75b4-431b-adb2-eb6b9e546014',
          'http://example.com/hello?source=xyz'
        )
      end
    end
  end
end
