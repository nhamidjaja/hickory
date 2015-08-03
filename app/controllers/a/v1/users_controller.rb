module A
  module V1
    class UsersController < A::V1::ApplicationController
      respond_to :json

      def show
        @user = User.find(params[:id])
      end

      def faves
        @faves = CUser.find(params[:id]).c_user_faves
      end
    end
  end
end
