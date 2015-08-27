require 'rails_helper'

RSpec.describe Follower, type: :model do
  it { expect(FactoryGirl.build(:follower)).to be_valid }
end
