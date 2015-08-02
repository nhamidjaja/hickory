require 'rails_helper'

RSpec.describe CUser, type: :model do
  it { expect(FactoryGirl.build(:c_user)).to be_valid }
  it { expect(FactoryGirl.build(:c_user, id: nil)).to_not be_valid }

  describe '.fave!' do
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
        id: nil
      )
    end
    let(:fave) do
      FactoryGirl.build(
        :c_user_fave,
        c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
        content_url: 'http://example.com/hello',
        id: '123e4567-e89b-12d3-a456-426655440000'
      )
    end

    context 'new fave_url' do
      describe 'without options' do
        subject { c_user.fave!(content) }

        it 'saves CUserFave and CUserFaveUrl' do
          expect(CUserFaveUrl).to receive(:find_or_initialize_by)
            .with(
              c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
              content_url: 'http://example.com/hello'
            )
            .and_yield(fave_url)
          expect(fave_url).to receive(:save!).with(consistency: :any).once

          expect(CUserFave).to receive(:new).with(
            c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
            id: an_instance_of(Cassandra::TimeUuid),
            content_url: 'http://example.com/hello',
            title: 'A headline',
            image_url: 'http://a.com/b.jpg',
            published_at: Time.zone.local('2014-03-11 11:00:00 +03:00')
          ).and_return(fave)
          expect(fave).to receive(:save!).with(consistency: :any).once

          is_expected.to eq(fave_url)
        end
      end

      describe 'with options' do
        subject { c_user.fave!(content, consistency: :one) }

        it 'saves CUserFave and CUserFaveUrl' do
          expect(CUserFaveUrl).to receive(:find_or_initialize_by)
            .with(
              c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
              content_url: 'http://example.com/hello'
            )
            .and_yield(fave_url)
          expect(fave_url).to receive(:save!).with(consistency: :one).once

          expect(CUserFave).to receive(:new).with(
            c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
            id: an_instance_of(Cassandra::TimeUuid),
            content_url: 'http://example.com/hello',
            title: 'A headline',
            image_url: 'http://a.com/b.jpg',
            published_at: Time.zone.local('2014-03-11 11:00:00 +03:00')
          ).and_return(fave)
          expect(fave).to receive(:save!).with(consistency: :one).once

          is_expected.to eq(fave_url)
        end
      end
    end

    context 'existing fave_url' do
      before do
        allow(fave_url).to receive(:new_record?).and_return(false)
      end

      subject { c_user.fave!(content) }

      it 'does not save CUserFave and CUserFaveUrl' do
        expect(CUserFaveUrl).to receive(:find_or_initialize_by)
          .with(
            c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
            content_url: 'http://example.com/hello'
          )
          .and_yield(fave_url)
        expect(fave_url).to_not receive(:save!)

        expect(CUserFave).to_not receive(:new)

        is_expected.to eq(fave_url)
      end
    end
  end
end
