class TopArticle < ActiveRecord::Base
  belongs_to :feeder

  validates :content_url, presence: true
  validates :feeder_id, presence: true
  validates :title, presence: true
  validates :image_url, presence: true
end
