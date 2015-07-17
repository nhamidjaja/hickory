class UserFaveUrl
  include Cequel::Record

  key :user_id, :uuid
  key :content_url, :text
  column :id, :timeuuid
  column :headline, :text
  column :image_url, :text
  column :following_fave_count, :int
  column :published_at, :timestamp

  timestamps

  validates :id, presence: true
end
