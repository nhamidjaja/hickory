class CUserFaveUrl
  include Cequel::Record
  include Cequelable

  belongs_to :c_user
  key :content_url, :text
  column :id, :timeuuid
  column :headline, :text
  column :image_url, :text
  column :following_fave_count, :int
  column :published_at, :timestamp
  column :faved_at, :timestamp

  timestamps

  validates :id, presence: true
end
