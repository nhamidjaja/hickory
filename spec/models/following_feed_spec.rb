require 'rails_helper'

RSpec.describe FollowingFeed, type: :model do
  it { expect(FactoryGirl.build(:following_feed)).to be_valid }
  it do
    expect(FactoryGirl.build(:following_feed, content_url: nil))
      .to_not be_valid
  end
  it do
    expect(FactoryGirl.build(:following_feed, faved_at: nil))
      .to_not be_valid
  end
end
