require 'rails_helper'

RSpec.describe Friend, type: :model do
  it { expect(FactoryGirl.build(:friend)).to be_valid }
end
