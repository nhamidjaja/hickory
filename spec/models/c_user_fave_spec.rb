require 'rails_helper'

RSpec.describe CUserFave, type: :model do
  it { expect(FactoryGirl.build(:c_user_fave)).to be_valid }

  it do
    expect(FactoryGirl.build(
             :c_user_fave,
             content_url: ''))
      .to_not be_valid
  end

  it do
    expect(FactoryGirl.build(
             :c_user_fave,
             faved_at: nil))
      .to_not be_valid
  end
end
