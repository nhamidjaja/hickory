module Api
  module V1
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session

      rescue_from StandardError, with: :render_internal_server_error
      rescue_from Errors::NotFound, with: :render_not_found
      rescue_from Errors::NotAuthorized, with: :render_unauthorized

      before_action :authenticate_user_from_token!

      # Tested with profile_requests_spec.rb
      def authenticate_user_from_token!
        token = request.headers['X-Auth-Token']
        user_email = request.headers['X-Email']
        user       = user_email && User.find_by_email(user_email)

        # Notice how we use Devise.secure_compare to compare the token
        # in the database with the token given in the params, mitigating
        # timing attacks.

        if user && Devise.secure_compare(user.authentication_token, token)
          sign_in user, store: false
          return
        end

        fail Errors::NotAuthorized
      end

      private

      def render_unauthorized(error)
        @error = error
        render('api/v1/errors/errors.json', status: :unauthorized)
      end

      def render_not_found(error)
        @error = error
        render('api/v1/errors/errors.json', status: :not_found)
      end

      def render_internal_server_error(error)
        @error = error
        render('api/v1/errors/errors.json', status: :internal_server_error)
      end
    end
  end
end
