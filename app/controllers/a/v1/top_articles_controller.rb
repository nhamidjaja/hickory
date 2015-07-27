module A
  module V1
    class TopArticlesController < ApplicationController
      respond_to :json

      def index
        @top_articles = TopArticle.latest_top(params[:limit],
                                              params[:last_published_at])
      end
    end
  end
end
