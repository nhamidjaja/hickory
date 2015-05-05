require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:user)).to be_valid
  end

  describe '.username' do
    it { expect(FactoryGirl.build(:user, username: '')).to_not be_valid }

    it 'is unique' do
      FactoryGirl.create(:user, username: 'a')

      expect(FactoryGirl.build(:user, username: 'a')).to_not be_valid
    end
  end
end
