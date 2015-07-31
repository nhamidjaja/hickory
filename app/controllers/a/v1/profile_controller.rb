module A
  module V1
    class ProfileController < A::V1::ApplicationController
      respond_to :json

      def index
      end

      def create
        @user = current_user

        if @user.update_attributes(user_params)
          render
        else
          render json: { errors: @user.errors }, status: 400
        end
      end

      # def update
      #   @user = User.find(current_user.id)

      #   @user.username = params[:username]

      #   @user.save!
      # end

      private

      def user_params
        params.require(:user).permit(:username)
      end
    end
  end
end
