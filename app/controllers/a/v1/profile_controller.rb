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
          render json: { user: { errors: @user.errors } }, status: 422
        end
      end

      private

      def user_params
        params.require(:user).permit(:username, :full_name, :description)
      end
    end
  end
end
