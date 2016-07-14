# frozen_string_literal: true
class Feeder < ActiveRecord::Base
  has_many :top_articles, dependent: :destroy

  validates :feed_url, presence: true, uniqueness: true
  validates :title, presence: true
end
