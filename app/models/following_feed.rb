class FollowingFeed
  include Cequel::Record

  belongs_to :c_user
  key :id, :timeuuid, order: :desc
  column :content_url, :text
  column :title, :text
  column :image_url, :text
  column :published_at, :timestamp
  column :faved_at, :timestamp

  timestamps

  validates :content_url, presence: true
  validates :faved_at, presence: true
end
