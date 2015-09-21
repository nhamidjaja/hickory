class Follower
  include Cequel::Record

  belongs_to :c_user
  key :id, :uuid

  validate :not_self_follower

  def not_self_follower
    errors.add(:id, 'Invalid to be a self follower') if c_user_id.eql?(id)
  end
end
