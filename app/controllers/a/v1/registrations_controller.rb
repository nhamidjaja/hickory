module A
  module V1
    class RegistrationsController < A::V1::ApplicationController
      skip_before_action :authenticate_user_from_token!
      rescue_from FbGraph2::Exception::InvalidToken, with: :render_unauthorized

      def facebook
        token = grab_facebook_token!
        user = fetch_user_from_facebook(token)

        begin
          user.save!
          UserMailer.welcome(user).deliver_later
          sign_in_and_render(user)
        rescue ActiveRecord::RecordInvalid => e
          warden.custom_failure!
          render_unprocessable_entity(e)
        end
      end

      private

      def user_params
        params.require(:user).permit(:username)
      end

      def grab_facebook_token!
        token = request.headers['X-Facebook-Token']
        fail(Errors::NotAuthorized, 'No Facebook token provided') unless token
      end

      def fetch_user_from_facebook(token)
        fb_user = FbGraph2::User.me(token).fetch
        user = User.new(user_params)
        user.apply_third_party_auth(Fave::Auth.from_facebook(fb_user))

        user
      end

      def sign_in_and_render(user)
        sign_in user, store: false
        render 'facebook', status: 201
      end
    end
  end
end
