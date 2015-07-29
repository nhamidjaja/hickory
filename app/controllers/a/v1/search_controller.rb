module A
  module V1
    class SearchController < ApplicationController
      respond_to :json

      def index
        @users = User.search_by_username(params[:query])
      end
    end
  end
end
    
