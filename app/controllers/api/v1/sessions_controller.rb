module Api
  module V1
    class SessionsController < Api::V1::ApplicationController
      skip_before_action :authenticate_user_from_token!

      def facebook
        fail Errors::NotAuthorized
      end
    end
  end
end
