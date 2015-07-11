module Api
  module V1
    class SessionsController < Api::V1::ApplicationController
      skip_before_action :authenticate_user_from_token!
      rescue_from FbGraph2::Exception::InvalidToken, with: :render_unauthorized

      def facebook
        token = request.headers['X-Facebook-Token']
        fail Errors::NotAuthorized unless token

        fb_user = nil
        me = FbGraph2::User.me(token)
        fb_user = me.fetch
      end
    end
  end
end
