# frozen_string_literal: true
module A
  module V1
    class TopArticlesController < ApplicationController
      def index
        @top_articles = TopArticle.since(params[:last_published_at]).take(50)
      end
    end
  end
end
