class Feeder < ActiveRecord::Base
  validates :feed_url, uniqueness: true
  validates :title, presence: true
end
