class TopArticle < ActiveRecord::Base
  belongs_to :feeder

  validates :content_url, presence: true
  validates :feeder_id, presence: true
  validates :title, presence: true
  validates :image_url, presence: true

  def self.latest_top(new_limit, last_published_at)
    limit = 50
    limit = new_limit if new_limit

    if last_published_at
      TopArticle.all.where(published_at:
        Time.zone.at(last_published_at.to_i)).order(published_at: :desc
                                                   ).take(limit)
    else
      TopArticle.all.order(published_at: :desc).take(limit)
    end
  end
end
