module A
  module V1
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session

      rescue_from StandardError, with: :render_internal_server_error
      rescue_from Errors::NotFound, with: :render_not_found
      rescue_from Errors::NotAuthorized, with: :render_unauthorized
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      prepend_before_action :disable_devise_trackable,
                            :authenticate_user_from_token

      # Tested with profile_requests_spec.rb
      def authenticate_user_from_token
        return if user_signed_in?

        token = request.headers['X-Auth-Token']
        user_email = request.headers['X-Email']
        user       = user_email && User.find_by_email(user_email)

        # Notice how we use Devise.secure_compare to compare the token
        # in the database with the token given in the params, mitigating
        # timing attacks.

        if user && Devise.secure_compare(user.authentication_token, token)
          record_request(user)
          sign_in user, store: false
          return
        end
      end

      protected

      def require_authentication!
        raise Errors::NotAuthorized, 'Failed to sign in' unless current_user
      end

      # http://icebergist.com/posts/how-to-skip-devise-trackable-updates/
      def disable_devise_trackable
        request.env['devise.skip_trackable'] = true
      end

      private

      def render_unauthorized(error)
        @error = error
        render('errors.json', status: :unauthorized)
      end

      def render_not_found(error)
        @error = error
        render('errors.json', status: :not_found)
      end

      def render_unprocessable_entity(error)
        @error = error
        render('errors.json', status: 422)
      end

      def render_internal_server_error(error)
        # TODO: log error
        NewRelic::Agent.notice_error(error)
        @error = error
        render('errors.json', status: :internal_server_error)
      end

      def record_request(user)
        return if user.proactive?

        user.record_current_request
        user.save
      end
    end
  end
end
