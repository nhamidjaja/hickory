require 'rails_helper'

RSpec.describe FollowingFeedWorker do
  describe '.perform' do
    let(:worker) { FollowingFeedWorker.new }
    let(:c_user) do
      FactoryGirl.build(:c_user, id: 'de305d54-75b4-431b-adb2-eb6b9e546014')
    end
    let(:target) do
      FactoryGirl.build(:c_user, id: '123e4567-e89b-12d3-a456-426655440000')
    end
    let(:following_feeds) do
      class_double('Cequel::Record::AssociationCollection')
    end
    let(:new_feed) { instance_double('FollowingFeed') }

    before do
      allow(CUser).to receive(:new)
        .with(id: 'de305d54-75b4-431b-adb2-eb6b9e546014')
        .and_return(c_user)

      allow(c_user).to receive(:following_feeds)
        .and_return(following_feeds)
      allow(following_feeds).to receive(:new).and_return(new_feed)
      allow(new_feed).to receive(:save!)
    end

    it do
      expect(following_feeds).to receive(:new)
        .with(
          id: Cequel.uuid('04390f20-5c23-11e5-885d-feff819cdc9f'),
          faver_id: '123e4567-e89b-12d3-a456-426655440000',
          content_url: 'http://example.com/xyz',
          title: 'Some headline',
          image_url: 'http://a.com/b.jpg',
          published_at: Time.zone.parse('2015-09-05 00:00:00 UTC'),
          faved_at: '2015-09-05 11:30:03 UTC'
        )
      expect(new_feed).to receive(:save!).with(consistency: :any)

      worker.perform(
        'de305d54-75b4-431b-adb2-eb6b9e546014',
        '123e4567-e89b-12d3-a456-426655440000',
        '04390f20-5c23-11e5-885d-feff819cdc9f',
        'http://example.com/xyz',
        'Some headline',
        'http://a.com/b.jpg',
        '2015-09-05 00:00:00 UTC',
        '2015-09-05 11:30:03 UTC'
      )
    end
  end
end
