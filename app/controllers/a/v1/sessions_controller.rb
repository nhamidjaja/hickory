module A
  module V1
    class SessionsController < A::V1::ApplicationController
      def facebook
        token = request.headers['X-Facebook-Token']
        raise(Errors::NotAuthorized, 'No Facebook token provided') unless token

        fb_user = fetch_facebook_user(token)
        user = User.from_third_party_auth(Fave::Auth.from_koala(fb_user, token))

        render_new_user(user) && return if user.new_record?

        user.record_new_session
        user.save!
        sign_in user, store: false
      end

      private

      def render_new_user(user)
        @user = user
        render 'new_user.json', status: :not_found
      end

      def fetch_facebook_user(token)
        graph = Koala::Facebook::API.new(token, Figaro.env.facebook_app_secret!)

        begin
          fb_user = graph.get_object('me', 'fields' => 'email,name,id,picture')
        rescue Koala::Facebook::APIError => e
          raise(Errors::NotAuthorized, e.message)
        end

        fb_user
      end
    end
  end
end
