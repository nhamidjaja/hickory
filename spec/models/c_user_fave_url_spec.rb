# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CUserFaveUrl, type: :model do
  it { expect(FactoryGirl.build(:c_user_fave_url)).to be_valid }

  it { expect(FactoryGirl.build(:c_user_fave_url, id: nil)).to_not be_valid }
  it do
    expect(FactoryGirl.build(:c_user_fave_url, faved_at: nil))
      .to_not be_valid
  end

  describe '#find_or_initialize_by' do
    let(:fave_url) do
      FactoryGirl.build(:c_user_fave_url,
                        c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                        content_url: 'http://example.com')
    end
    subject do
      CUserFaveUrl
        .find_or_initialize_by(
          c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
          content_url: 'http://example.com'
        )
    end

    context 'found' do
      it 'has content' do
        expect(CUserFaveUrl).to receive(:where)
          .with(c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                content_url: 'http://example.com')
          .and_return([fave_url])

        is_expected.to eq(fave_url)
      end
    end

    context 'not found' do
      it 'is new' do
        expect(CUserFaveUrl).to receive(:where)
          .with(c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                content_url: 'http://example.com')
          .and_return([])
        expect(CUserFaveUrl).to receive(:new)
          .with(c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                content_url: 'http://example.com')
          .and_return(fave_url)

        is_expected.to eq(fave_url)
      end
    end
  end
end
