class Following
  include Cequel::Record

  belongs_to :c_user
  key :id, :uuid

  validate :not_following_self

  def not_following_self
    errors.add(:id, 'Invalid to be following self') if c_user_id.eql?(id)
  end
end
