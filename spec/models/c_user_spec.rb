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

    before do
      expect(CUserFave).to receive(:new)
        .with(
          c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
          id: an_instance_of(Cassandra::TimeUuid),
          content_url: 'http://example.com/hello',
          title: 'A headline',
          image_url: 'http://a.com/b.jpg',
          published_at: Time.zone.local('2014-03-11 11:00:00 +03:00')
        )
        .and_return(fave)
      expect(CUserFaveUrl).to receive(:new)
        .with(
          c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
          content_url: 'http://example.com/hello',
          id: an_instance_of(Cassandra::TimeUuid)
        )
        .and_return(fave_url)
      allow_any_instance_of(CUser).to receive(:increment_faves_counter)
    end

    subject { c_user.fave(content) }

    it 'saves CUserFave and CUserFaveUrl' do
      expect(fave).to receive(:save!).with(consistency: :any).and_return(fave)
      expect(fave_url).to receive(:save!)
        .with(consistency: :any)
        .and_return(fave_url)

      is_expected.to eq(true)
    end

    it 'increments faves counter' do
      expect(c_user).to receive(:increment_faves_counter)

      subject
    end
  end
end
