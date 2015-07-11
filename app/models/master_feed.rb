class MasterFeed
  include Cequel::Record

  key :content_url, :text
  column :headline, :text
  column :header_image_url, :text
  column :total_fave_count, :int
  column :published_at, :timestamp

  timestamps
end
