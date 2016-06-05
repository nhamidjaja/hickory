module A
  module V1
    class SearchController < ApplicationController
      skip_before_action :authenticate_user_from_token!

      def index
        @users = []
        return unless params[:query]

        @users = User.search(params[:query]).take(10)
      end
    end
  end
end
