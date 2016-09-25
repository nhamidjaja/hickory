# frozen_string_literal: true
class FeedersUser < ActiveRecord::Base
  belongs_to :feeder
  belongs_to :user

  has_many :top_articles, primary_key: :feeder_id, foreign_key: :feeder_id
end
