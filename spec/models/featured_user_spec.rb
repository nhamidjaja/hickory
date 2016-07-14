# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FeaturedUser, type: :model do
  it { expect(FactoryGirl.build(:featured_user)).to be_valid }

  describe '.priority' do
    it { expect(FactoryGirl.build(:featured_user, priority: 0)).to be_valid }

    it do
      expect(FactoryGirl.build(:featured_user, priority: -1))
        .to_not be_valid
    end
    it do
      expect(FactoryGirl.build(:featured_user, priority: 10))
        .to_not be_valid
    end
  end
end
