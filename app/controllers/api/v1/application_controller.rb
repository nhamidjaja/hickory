module Api
  module V1
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session


      # Tested with profile_requests_spec.rb
      def authenticate_user!
        email = request.headers['X-Email']
        token = request.headers['X-Auth-Token']
        render_unauthorized && return unless email && token

        user = User.find_by_email(email)
        render_not_found && return unless user
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
