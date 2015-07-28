class TopArticle < ActiveRecord::Base
  belongs_to :feeder

  validates :content_url, presence: true
  validates :title, presence: true
  validates :image_url, presence: true

  def self.latest_top(last_published_at = nil, limit = 50)
    limit ||= 50

    if last_published_at
      TopArticle.where('published_at <= ?',
                       Time.zone.at(last_published_at.to_i)).order(
                         published_at: :desc).take(limit)
    else
      TopArticle.all.order(published_at: :desc).take(limit)
    end
  end
end
