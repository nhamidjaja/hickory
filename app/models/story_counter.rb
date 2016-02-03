class StoryCounter
  include Cequel::Record

  belongs_to :c_user
  key :story_id, :timeuuid, order: :desc
  column :views, :counter

  validates :c_user_id, presence: true
  validates :story_id, presence: true

  def views
    self[:views] || 0
  end
end
