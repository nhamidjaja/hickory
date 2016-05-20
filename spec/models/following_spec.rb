require 'rails_helper'

RSpec.describe Following, type: :model do
  it { expect(FactoryGirl.build(:following)).to be_valid }

  describe '.not_following_self' do
    let(:c_user) { FactoryGirl.build(:c_user) }

    it do
      expect(FactoryGirl.build(
               :following,
               c_user: c_user,
               id: c_user.id
      ))
        .to_not be_valid
    end
  end
end
