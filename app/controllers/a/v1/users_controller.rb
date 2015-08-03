module A
  module V1
    class UsersController < A::V1::ApplicationController
      respond_to :json

      def show
        @user = User.find(params[:id])
      end

      def faves
        if params[:last_id]
          @faves = CUser.find(params[:id]).c_user_faves.before(
            Cequel.uuid(params[:last_id])).reverse.limit(10)
        else
          @faves = CUser.find(params[:id]).c_user_faves.reverse.limit(10)
        end
      end
    end
  end
end
