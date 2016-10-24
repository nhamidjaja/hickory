# frozen_string_literal: true
class Feeder < ActiveRecord::Base
  include PgSearch

  has_many :top_articles, dependent: :destroy
  has_many :feeders_users, dependent: :destroy
  has_many :users, through: :feeders_users

  validates :feed_url, presence: true, uniqueness: true
  validates :title, presence: true

  pg_search_scope :search,
                  against: [:title],
                  using: {
                    tsearch: { prefix: true }
                  }
end
