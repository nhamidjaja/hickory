require 'rails_helper'

RSpec.describe CUser, type: :model do
  it { expect(FactoryGirl.build(:c_user)).to be_valid }
  it { expect(FactoryGirl.build(:c_user, id: nil)).to_not be_valid }

  describe '.fave' do
    let(:c_user) do
      FactoryGirl.build(
        :c_user,
        id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014')
      )
    end
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
        c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
        content_url: 'http://example.com/hello',
        id: Cequel.uuid('123e4567-e89b-12d3-a456-426655440000')
      )
    end
    let(:fave) do
      FactoryGirl.build(
        :c_user_fave,
        c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
        content_url: 'http://example.com/hello',
        id: Cequel.uuid('123e4567-e89b-12d3-a456-426655440000')
      )
    end
    let(:faved_at) { Time.zone.parse('2015-08-18 05:31:28 UTC').utc }

    before do
      expect(c_user.c_user_faves).to receive(:new)
        .with(
          id: an_instance_of(Cassandra::TimeUuid),
          content_url: 'http://example.com/hello',
          title: 'A headline',
          image_url: 'http://a.com/b.jpg',
          published_at: Time.zone.local('2014-03-11 11:00:00 +03:00'),
          faved_at: faved_at
        )
        .and_return(fave)
      expect(c_user.c_user_fave_urls).to receive(:new)
        .with(
          content_url: 'http://example.com/hello',
          id: an_instance_of(Cassandra::TimeUuid),
          faved_at: faved_at
        )
        .and_return(fave_url)
      allow_any_instance_of(CUser).to receive(:increment_faves_counter)
    end

    subject { c_user.fave(content, faved_at) }

    it 'saves CUserFave and CUserFaveUrl' do
      expect(fave).to receive(:save!).with(consistency: :any).and_return(fave)
      expect(fave_url).to receive(:save!)
        .with(consistency: :any)
        .and_return(fave_url)

      is_expected.to eq(fave)
    end

    it 'increments faves counter' do
      expect(c_user).to receive(:increment_faves_counter)

      subject
    end
  end

  describe '.follow' do
    let(:user) do
      FactoryGirl.build(:c_user,
                        id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end
    let(:friend) do
      FactoryGirl.build(:c_user,
                        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end

    let(:data_set) { instance_double('Cequel::Metal::DataSet') }

    before do
      allow_any_instance_of(Following).to receive(:save!)
      allow_any_instance_of(Follower).to receive(:save!)
      allow(user).to receive(:following?).with(friend)
        .and_return(false)
      allow(user).to receive(:increment_follow_counters).with(friend)
    end

    it 'saves into Following' do
      double = instance_double('Following')
      expect(user.followings).to receive(:new)
        .with(id: Cequel.uuid('4f16d362-a336-4b12-a133-4b8e39be7f8e'))
        .and_return(double)
      expect(double).to receive(:save!) # .with(consistency: :any)

      user.follow(friend)
    end

    it 'saves into Follower' do
      double = instance_double('Follower')
      expect(friend.followers).to receive(:new)
        .with(id: Cequel.uuid('9d6831a4-39d1-11e5-9128-17e501c711a8'))
        .and_return(double)
      expect(double).to receive(:save!) # .with(consistency: :any)

      user.follow(friend)
    end

    it 'increments following counter' do
      expect(user).to receive(:increment_follow_counters).with(friend)

      user.follow(friend)
    end
  end

  describe '.unfollow' do
    let(:user) do
      FactoryGirl.build(:c_user,
                        id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end
    let(:friend) do
      FactoryGirl.build(:c_user,
                        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end

    let(:data_set) { instance_double('Cequel::Metal::DataSet') }

    before do
      allow_any_instance_of(Cequel::Record::RecordSet).to receive(:delete_all)
      allow(user).to receive(:following?).with(friend)
        .and_return(true)
      allow(user).to receive(:increment_follow_counters).with(friend)
    end

    it 'deletes Following' do
      double = instance_double('Cequel::Record::RecordSet')
      expect(user.followings).to receive(:where)
        .with(id: Cequel.uuid('4f16d362-a336-4b12-a133-4b8e39be7f8e'))
        .and_return(double)
      expect(double).to receive(:delete_all) # .with(consistency: :any)

      user.unfollow(friend)
    end

    it 'deletes Follower' do
      double = instance_double('Cequel::Record::RecordSet')
      expect(friend.followers).to receive(:where)
        .with(id: Cequel.uuid('9d6831a4-39d1-11e5-9128-17e501c711a8'))
        .and_return(double)
      expect(double).to receive(:delete_all) # .with(consistency: :any)

      user.unfollow(friend)
    end

    it 'increments following counter' do
      expect(user).to receive(:decrement_follow_counters).with(friend)

      user.unfollow(friend)
    end
  end

  describe '.following?' do
    let(:user) do
      FactoryGirl.build(:c_user,
                        id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end
    let(:friend) do
      FactoryGirl.build(:c_user,
                        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end

    context 'not following' do
      before do
        allow(Following).to receive(:where)
          .with(
            c_user_id: Cequel.uuid('9d6831a4-39d1-11e5-9128-17e501c711a8'),
            id: Cequel.uuid('4f16d362-a336-4b12-a133-4b8e39be7f8e')
          )
          .and_return([])
      end

      it { expect(user.following?(friend)).to eq(false) }
    end

    context 'following' do
      before do
        allow(user.followings).to receive(:where)
          .with(id: Cequel.uuid('4f16d362-a336-4b12-a133-4b8e39be7f8e'))
          .and_return([Following.new])
      end

      it { expect(user.following?(friend)).to eq(true) }
    end
  end
end
