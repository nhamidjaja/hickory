class Gcm < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: :true
  validates :registration_id, presence: :true
end
