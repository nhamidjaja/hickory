class Gcm < ActiveRecord::Base
  belongs_to :user

  validates :registration_token, presence: :true
end
