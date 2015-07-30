class Content
  include Cequel::Record

  key :url, :text
  column :title, :text
  column :image_url, :text
  column :published_at, :timestamp
end
