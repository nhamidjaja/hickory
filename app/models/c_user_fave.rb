# This is a reverse implementation of CUserFaveUrl
class CUserFave
  include Cequel::Record

  belongs_to :c_user
  key :id, :timeuuid, order: :desc
  column :content_url, :text
  column :title, :text
  column :image_url, :text
  column :following_fave_count, :int
  column :published_at, :timestamp

  timestamps
end
