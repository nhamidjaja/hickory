# frozen_string_literal: true
class FeaturedUser < ActiveRecord::Base
  belongs_to :user

  validates :priority, inclusion: 0..9
end
