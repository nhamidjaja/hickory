class Feeder < ActiveRecord::Base
  validates :feed_url, presence: true, uniqueness: true
  validates :title, presence: true
end
