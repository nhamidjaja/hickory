module Api
  module V1
    class SessionsController < Api::V1::ApplicationController
      skip_before_action :authenticate_user_from_token!
      rescue_from FbGraph2::Exception::InvalidToken, with: :render_unauthorized

      def facebook
        token = request.headers['X-Facebook-Token']
        fail(Errors::NotAuthorized, 'No Facebook token provided') unless token

        fb_user = FbGraph2::User.me(token).fetch
        user = User.from_third_party_auth(Fave::Auth.from_facebook(fb_user))

        fail(Errors::NotFound, 'Unregistered user') if user.new_record?

        user.save!
        sign_in user, store: false
      end
    end
  end
end
