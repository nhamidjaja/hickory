# frozen_string_literal: true
module A
  module V1
    class UsersController < A::V1::ApplicationController
      before_action :require_authentication!,
                    only: [:follow, :unfollow]

      def show
        @current_user = current_user || NilUser.new
        @user = User.find(params[:id])
        @recent_faves = @user.faves(nil, 20)
      end

      def faves
        user = User.find(params[:id])
        @faves = user.faves(params[:last_id], 10)
      end

      def follow
        target = User.find(params[:id])

        if current_user.eql?(target)
          render json: {
            errors: { message: 'Cannot follow self' }
          }, status: 422
          return
        end

        FollowUserWorker.perform_async(current_user.id, target.id)

        render json: {}
      end

      def unfollow
        target = User.find(params[:id])

        UnfollowUserWorker.perform_async(current_user.id, target.id)

        render json: {}
      end

      def followers
        @user = User.find(params[:id])
        @followers = @user.in_cassandra.followers

        last_id = params[:last_id]
        @followers = @followers.after(Cequel.uuid(last_id)) if last_id

        @followers = @followers.limit(30)
      end

      def followings
        @user = User.find(params[:id])
        @followings = @user.in_cassandra.followings

        last_id = params[:last_id]
        @followings = @followings.after(Cequel.uuid(last_id)) if last_id

        @followings = @followings.limit(30)
      end
    end
  end
end
