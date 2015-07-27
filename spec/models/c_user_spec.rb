require 'rails_helper'

RSpec.describe CUser, type: :model do
  it { expect(FactoryGirl.build(:c_user)).to be_valid }
end
