# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NilUser do
  describe '.following?' do
    it 'is false' do
      user = FactoryGirl.build(:user)

      expect(NilUser.new.following?(user)).to eq(false)
    end
  end
end
