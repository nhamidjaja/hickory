# frozen_string_literal: true
class Gcm < ActiveRecord::Base
  self.primary_key = :registration_token

  belongs_to :user

  validates :registration_token, presence: :true
end
