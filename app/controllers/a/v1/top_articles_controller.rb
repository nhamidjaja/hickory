module A
  module V1
    class TopArticlesController < ApplicationController
      respond_to :json

      def index
        @top_articles = TopArticle.all.take(50)
      end
    end
  end
end
