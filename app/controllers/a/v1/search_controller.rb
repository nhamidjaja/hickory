module A
  module V1
    class SearchController < ApplicationController
      respond_to :json

      def index
        @users = []
        return unless params[:query]

        @users = User.search_by_username(params[:query]).take(10)
      end
    end
  end
end
