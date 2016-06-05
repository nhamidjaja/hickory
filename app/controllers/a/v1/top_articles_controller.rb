module A
  module V1
    class TopArticlesController < ApplicationController
      skip_before_action :authenticate_user_from_token!

      def index
        @top_articles = TopArticle.since(params[:last_published_at]).take(50)
      end
    end
  end
end
