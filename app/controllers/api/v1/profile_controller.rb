module Api
  module V1
    class ProfileController < Api::V1::ApplicationController
      before_action :authenticate_user_from_token!
      respond_to :json

      def index
      end
    end
  end
end
