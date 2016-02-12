require 'rails_helper'

RSpec.describe CUserCounter, type: :model do
  it { expect(FactoryGirl.build(:c_user_counter)).to be_valid }

  it do
    expect(FactoryGirl.build(:c_user_counter, c_user_id: nil))
      .to_not be_valid
  end

  describe '.faves' do
    it do
      expect(FactoryGirl.build(:c_user_counter, faves: 12).faves)
        .to eq(12)
    end
    it do
      expect(FactoryGirl.build(:c_user_counter, faves: nil).faves)
        .to eq(0)
    end
  end

  describe '.followers' do
    it do
      expect(FactoryGirl.build(:c_user_counter, followers: 9).followers)
        .to eq(9)
    end
    it do
      expect(FactoryGirl.build(:c_user_counter, followers: nil).followers)
        .to eq(0)
    end
  end

  describe '.followings' do
    it do
      expect(FactoryGirl.build(:c_user_counter, followings: 10_000).followings)
        .to eq(10_000)
    end
    it do
      expect(FactoryGirl.build(:c_user_counter, followings: nil).followings)
        .to eq(0)
    end
  end
end
