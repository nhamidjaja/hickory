module A
  module V1
    class RegistrationsController < A::V1::ApplicationController
      skip_before_action :authenticate_user_from_token!
      rescue_from FbGraph2::Exception::InvalidToken, with: :render_unauthorized

      def facebook
        token = request.headers['X-Facebook-Token']
        fail(Errors::NotAuthorized, 'No Facebook token provided') unless token

        fb_user = FbGraph2::User.me(token).fetch
        user = User.new(user_params)
        user.apply_third_party_auth(Fave::Auth.from_facebook(fb_user))

        if user.save
          UserMailer.welcome(user).deliver_later
          return sign_in_and_render(user)
        end

        invalid_user_creation(user)
      end

      private

      def user_params
        params.require(:user).permit(:username)
      end

      def sign_in_and_render(user)
        sign_in user, store: false
        render 'facebook', status: 201
      end

      def invalid_user_creation(user)
        warden.custom_failure!
        render json: { user: { errors: user.errors } }, status: 422
      end
    end
  end
end
