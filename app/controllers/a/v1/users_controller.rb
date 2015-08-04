module A
  module V1
    class UsersController < A::V1::ApplicationController
      respond_to :json

      def show
        @user = User.find(params[:id])
      end

      def faves
        user = User.find(params[:id])
        @faves = user.faves(params[:last_id], 10)
      end
    end
  end
end
