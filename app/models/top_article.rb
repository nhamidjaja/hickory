class TopArticle < ActiveRecord::Base
  belongs_to :feeder

  validates :content_url, presence: true
  validates :title, presence: true
  validates :image_url, presence: true

  def self.latest_top(last_published_at, limit)
    limit ||= 50

    articles = TopArticle.all

    if last_published_at
      articles = articles.where('published_at <= ?',
                                Time.zone.at(last_published_at.to_i).utc)
    end

    articles.order(published_at: :desc).take(limit)
  end
end
