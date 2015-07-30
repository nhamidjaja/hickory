require 'rails_helper'

RSpec.describe CUserFaveUrl, type: :model do
  it { expect(FactoryGirl.build(:c_user_fave_url)).to be_valid }

  it { expect(FactoryGirl.build(:c_user_fave_url, id: nil)).to_not be_valid }
end
