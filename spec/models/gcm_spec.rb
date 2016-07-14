# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Gcm, type: :model do
  it { expect(FactoryGirl.build(:gcm)).to be_valid }

  it { expect(FactoryGirl.build(:gcm, registration_token: '')).to_not be_valid }
end
