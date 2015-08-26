require 'rails_helper'

RSpec.describe CUserCounter, type: :model do
  it { expect(FactoryGirl.build(:c_user_counter)).to be_valid }
end
