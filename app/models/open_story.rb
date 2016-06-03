class OpenStory < ActiveRecord::Base
  include Storyable

  validates :faver_id, presence: true
  validates :content_url, presence: true
  validates :faved_at, presence: true
end
