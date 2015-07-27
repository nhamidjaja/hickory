class CUserFave
  include Cequel::Record

  belongs_to :c_user
  key :id, :timeuuid
  column :content_url, :text
  column :headline, :text
  column :image_url, :text
  column :following_fave_count, :int
  column :published_at, :timestamp

  timestamps
end
