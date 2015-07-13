class MasterFeed
  include Cequel::Record

  key :content_url, :text
  column :headline, :text
  column :image_url, :text
  column :total_fave_count, :int
  column :published_at, :timestamp

  timestamps

  before_save :canonicalize_url

  def canonicalize_url
    url = Fave::Url.new(self.content_url)
    self.content_url = url.canon
  end
end
