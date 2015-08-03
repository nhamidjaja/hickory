class Content
  include Cequel::Record
  include Cequelable

  key :url, :text
  column :title, :text
  column :image_url, :text
  column :published_at, :timestamp

  validates :url, presence: true
end
