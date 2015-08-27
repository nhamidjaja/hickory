class CUserCounter
  include Cequel::Record
  include Cequelable

  belongs_to :c_user
  column :faves, :counter
  column :followers, :counter
  column :followings, :counter

  validates :c_user_id, presence: true
end
