class Feeder < ActiveRecord::Base
  # TODO: change id to uuid type
  validates :feed_url, uniqueness: true
  validates :title, presence: true
end
