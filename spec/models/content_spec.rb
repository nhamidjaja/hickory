require 'rails_helper'

RSpec.describe Content, type: :model do
  it { expect(FactoryGirl.build(:content)).to be_valid }
end
