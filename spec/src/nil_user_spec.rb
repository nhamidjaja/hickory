# frozen_string_literal: true
require 'rails_helper'

RSpec.describe NilUser do
  let(:user) { NilUser.new }

  describe '.following?' do
    it 'is false' do
      target = FactoryGirl.build(:user)

      expect(user.following?(target)).to eq(false)
    end
  end

  describe '.subscribing?' do
    it 'is false' do
      feeder = FactoryGirl.build(:feeder)

      expect(user.subscribing?(feeder)).to eq(false)
    end
  end
end
