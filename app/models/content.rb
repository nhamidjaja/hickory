# frozen_string_literal: true
class Content
  include Cequel::Record
  include Cequelable

  key :url, :text
  column :title, :text
  column :image_url, :text
  column :published_at, :timestamp

  validates :url, presence: true

  def url=(value)
    self[:url] = Fave::Url.new(value).canon if value.present?
  end
end
