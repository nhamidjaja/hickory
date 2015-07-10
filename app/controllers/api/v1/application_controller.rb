module Api
  module V1
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session
      rescue_from Errors::NotFound, with: :render_not_found
      rescue_from Errors::NotAuthorized, with: :render_unauthorized

      @current_user = nil

      # Tested with profile_requests_spec.rb
      def authenticate_user!
        email = request.headers['X-Email']
        token = request.headers['X-Auth-Token']
        fail Errors::NotAuthorized unless email && token

        user = User.find_by_email(email)
        fail Errors::NotAuthorized unless user

        return @current_user = user if user.omniauth_token.eql?(token)

        fail Errors::NotAuthorized
      end

      private

      def render_unauthorized
        render(json: {}, status: :unauthorized)
      end

      def render_not_found
        render(json: {}, status: :not_found)
      end
    end
  end
end
