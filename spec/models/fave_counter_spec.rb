# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FaveCounter, type: :model do
  it { expect(FactoryGirl.build(:fave_counter)).to be_valid }

  it do
    expect(FactoryGirl.build(
             :fave_counter, c_user_id: nil
    )).to_not be_valid
  end
  it do
    expect(FactoryGirl.build(
             :fave_counter, id: nil
    )).to_not be_valid
  end

  describe '.views' do
    it do
      expect(FactoryGirl.build(:fave_counter, views: 77).views)
        .to eq(77)
    end

    it do
      expect(FactoryGirl.build(:fave_counter, views: nil).views)
        .to eq(0)
    end
  end
end
