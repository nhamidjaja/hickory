require 'rails_helper'

RSpec.describe CUserFave, type: :model do
  it { expect(FactoryGirl.build(:c_user_fave)).to be_valid }
end
