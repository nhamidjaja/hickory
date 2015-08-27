module A
  module V1
    class UsersController < A::V1::ApplicationController
      respond_to :json

      def show
        @user = User.find(params[:id])
        @recent_faves = @user.faves(nil, 20)
      end

      def faves
        user = User.find(params[:id])
        @faves = user.faves(params[:last_id], 10)
      end

      def follow
        target = User.find(params[:id])

        FollowUserWorker.perform_async(current_user.id, target.id)

        render json: {}
      end

      def unfollow
        target = User.find(params[:id])

        UnfollowUserWorker.perform_async(current_user.id, target.id)

        render json: {}
      end
    end
  end
end
