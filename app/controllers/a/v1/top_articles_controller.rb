module A
  module V1
    class TopArticlesController < ApplicationController
      respond_to :json

      def index
        @top_articles = TopArticle.latest_top(params[:last_published_at],params[:limit])
      end
    end
  end
end
