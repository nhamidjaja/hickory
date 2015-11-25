module A
  module V1
    class SearchController < ApplicationController
      respond_to :json

      def index
        @users = []
        return unless params[:query]

        @users = User.search(params[:query]).take(10)
      end
    end
  end
end
