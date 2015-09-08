require 'rails_helper'

RSpec.describe FaveFollowWorker do
  describe '.perform' do
    let(:worker) { FaveFollowWorker.new }
    let(:c_user) do
      FactoryGirl.build(:c_user, id: 'de305d54-75b4-431b-adb2-eb6b9e546014')
    end
    let(:fave_id) { Cequel.uuid(Time.zone.now.utc) }
    let(:following_feeds) do
      class_double('Cequel::Record::AssociationCollection')      
    end

    before do
      allow(CUser).to receive(:new)
        .with(id: 'de305d54-75b4-431b-adb2-eb6b9e546014')
        .and_return(c_user)

      allow(c_user).to receive(:following_feeds)
        .and_return(following_feeds)
      new_feed = instance_double('FollowingFeed')
      allow(following_feeds).to receive(:new).and_return(new_feed)
      allow(new_feed).to receive(:save!)
    end

    it do
      expect(following_feeds).to receive(:new)
        .with(
          id: fave_id.to_s,
          faver_id: '123e4567-e89b-12d3-a456-426655440000',
          content_url: 'http://example.com/xyz',
          title: 'Some headline',
          image_url: 'http://a.com/b.jpg',
          published_at: '2015-09-05 00:00:00 UTC',
          faved_at: '2015-09-05 11:30:03 UTC'
          )

      worker.perform(
        'de305d54-75b4-431b-adb2-eb6b9e546014',
        '123e4567-e89b-12d3-a456-426655440000',
        fave_id.to_s,
        'http://example.com/xyz',
        'Some headline',
        'http://a.com/b.jpg',
        '2015-09-05 00:00:00 UTC',
        '2015-09-05 11:30:03 UTC'
        )
    end
  end
end
