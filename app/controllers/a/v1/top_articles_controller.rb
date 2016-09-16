# frozen_string_literal: true
module A
  module V1
    class TopArticlesController < ApplicationController
      def index
        @top_articles = TopArticle.order('RANDOM()').limit(30)
      end
    end
  end
end
