# frozen_string_literal: true
class Feeder < ActiveRecord::Base
  has_many :top_articles, dependent: :destroy
  has_many :feeders_users, dependent: :destroy
  has_many :users, through: :feeders_users

  validates :feed_url, presence: true, uniqueness: true
  validates :title, presence: true
end
