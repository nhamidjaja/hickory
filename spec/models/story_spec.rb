require 'rails_helper'

RSpec.describe Story, type: :model do
  it { expect(FactoryGirl.build(:story)).to be_valid }

  it do
    expect(FactoryGirl.build(:story,
                             faver_id: nil)).to_not be_valid
  end
  it do
    expect(FactoryGirl.build(:story, content_url: nil))
      .to_not be_valid
  end
  it do
    expect(FactoryGirl.build(:story, faved_at: nil))
      .to_not be_valid
  end
end
