class TopArticle < ActiveRecord::Base
  belongs_to :feeder

  validates :content_url, presence: true
  validates :title, presence: true
  validates :image_url, presence: true

  def self.latest_top(last_published_at = Time.zone.now.to_i, limit = 50)
    last_published_at ||= Time.zone.now.to_i
    limit ||= 50

    TopArticle.all.where('published_at <= ?',
                         Time.zone.at(last_published_at.to_i)).order(
                           published_at: :desc).take(limit)
  end
end
