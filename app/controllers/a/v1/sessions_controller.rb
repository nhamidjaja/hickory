module A
  module V1
    class SessionsController < A::V1::ApplicationController
      skip_before_action :authenticate_user_from_token!

      def facebook
        token = request.headers['X-Facebook-Token']
        raise(Errors::NotAuthorized, 'No Facebook token provided') unless token

        fb_user = fetch_facebook_user(token)
        user = User.from_third_party_auth(Fave::Auth.from_koala(fb_user, token))

        raise(Errors::NotFound, 'Unregistered user') if user.new_record?

        user.record_new_session
        user.save!
        sign_in user, store: false
      end

      private

      def fetch_facebook_user(token)
        graph = Koala::Facebook::API.new(token, Figaro.env.facebook_app_secret!)

        begin
          fb_user = graph.get_object('me')
        rescue Koala::Facebook::APIError => e
          raise(Errors::NotAuthorized, e.message)
        end

        fb_user
      end
    end
  end
end
