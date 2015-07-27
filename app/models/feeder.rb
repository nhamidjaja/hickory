class Feeder < ActiveRecord::Base
  has_many :top_articles, dependent: :destroy

  validates :feed_url, presence: true, uniqueness: true
  validates :title, presence: true

  def self.top_articles
    Feeder.joins(:top_articles).select('feed_url',
                                       'feeders.title as feed_title',
                                       'top_articles.title as title',
                                       'content_url', 'image_url',
                                       'published_at'
                                      ).order('top_articles.published_at DESC'
                                             ).to_a
  end
end
