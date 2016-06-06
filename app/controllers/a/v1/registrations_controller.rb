module A
  module V1
    class RegistrationsController < A::V1::ApplicationController
      def facebook
        token = grab_facebook_token!
        user = fetch_user_from_facebook(token)

        begin
          user.save!
          after_registration(user)
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
        raise(Errors::NotAuthorized, 'No Facebook token provided') unless token

        token
      end

      def fetch_user_from_facebook(token)
        graph = Koala::Facebook::API.new(token, Figaro.env.facebook_app_secret!)

        begin
          fb_user = graph.get_object('me', 'fields' => 'email,name,id,picture')
        rescue Koala::Facebook::APIError => e
          raise(Errors::NotAuthorized, e.message)
        end

        user = User.new(user_params)
        user.apply_third_party_auth(Fave::Auth.from_koala(fb_user, token))

        user
      end

      def sign_in_and_render(user)
        sign_in user, store: false
        render 'facebook', status: 201
      end

      def after_registration(user)
        UserMailer.tcc_announce(user).deliver_later
        GetFriendsFromFacebookWorker.perform_async(user.id.to_s)
      end
    end
  end
end
