require 'rails_helper'

RSpec.describe Follower, type: :model do
  it { expect(FactoryGirl.build(:follower)).to be_valid }

  describe '.not_self_follower' do
    let(:c_user) { FactoryGirl.build(:c_user) }

    it do
      expect(FactoryGirl.build(
               :follower,
               c_user: c_user,
               id: c_user.id
      ))
        .to_not be_valid
    end
  end
end
