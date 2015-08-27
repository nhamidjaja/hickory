require 'rails_helper'

RSpec.describe Following, type: :model do
  it { expect(FactoryGirl.build(:following)).to be_valid }
end
