require 'rails_helper'

RSpec.describe FeaturedUser, type: :model do
  it { expect(FactoryGirl.build(:featured_user)).to be_valid }
end
