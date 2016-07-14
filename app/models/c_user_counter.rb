# frozen_string_literal: true
class CUserCounter
  include Cequel::Record
  include Cequelable

  belongs_to :c_user
  column :faves, :counter
  column :followers, :counter
  column :followings, :counter

  validates :c_user_id, presence: true

  def faves
    self[:faves] || 0
  end

  def followers
    self[:followers] || 0
  end

  def followings
    self[:followings] || 0
  end
end
