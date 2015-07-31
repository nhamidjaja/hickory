module A
  module V1
    class ProfileController < A::V1::ApplicationController
      respond_to :json

      def index
      end

      def update
        @user = User.find(current_user.id)

        @user.username = params[:username]

        @user.save!
      end
    end
  end
end
