module A
  module V1
    class TopArticlesController < ApplicationController
      respond_to :json

      def index
        @top_articles = TopArticle
          .since(params[:last_published_at])
          .take(50)
      end
    end
  end
end
