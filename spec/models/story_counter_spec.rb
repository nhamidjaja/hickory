require 'rails_helper'

RSpec.describe StoryCounter, type: :model do
  it { expect(FactoryGirl.build(:story_counter)).to be_valid }

  it { expect(FactoryGirl.build(
    :story_counter, c_user_id: nil)).to_not be_valid }
  it { expect(FactoryGirl.build(
    :story_counter, story_id: nil)).to_not be_valid }

  describe '.views' do
    it do
      expect(FactoryGirl.build(:story_counter, views: 77).views)
        .to eq(77)
    end

    it do
      expect(FactoryGirl.build(:story_counter, views: nil).views)
        .to eq(0)
    end
  end
end
