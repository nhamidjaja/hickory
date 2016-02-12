class FaveCounter
  include Cequel::Record

  belongs_to :c_user
  key :id, :timeuuid, order: :desc
  column :views, :counter

  validates :c_user_id, presence: true
  validates :id, presence: true

  def views
    self[:views] || 0
  end
end
