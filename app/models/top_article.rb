# frozen_string_literal: true
class TopArticle < ActiveRecord::Base
  belongs_to :feeder
  belongs_to :feeders_user, foreign_key: :feeder_id, primary_key: :id

  validates :content_url, presence: true
  validates :title, presence: true

  def self.since(last_published_at)
    articles = TopArticle.all.order(published_at: :desc)

    if last_published_at
      articles = articles.where('published_at < ?',
                                Time.zone.at(last_published_at.to_i).utc)
    end

    articles
  end
end
