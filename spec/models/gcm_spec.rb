require 'rails_helper'

RSpec.describe Gcm, type: :model do
  it { expect(FactoryGirl.build(:gcm)).to be_valid }

  it { expect(FactoryGirl.build(:gcm, user_id: nil)).to_not be_valid }
  it { expect(FactoryGirl.build(:gcm, registration_id: '')).to_not be_valid }
end
