require 'rails_helper'

RSpec.describe UserFaveUrl, type: :model do
  it { expect(FactoryGirl.create(:user_fave_url)).to be_valid }

  it { expect(FactoryGirl.build(:user_fave_url, id: nil)).to_not be_valid }
end
