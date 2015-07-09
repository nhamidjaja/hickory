module Api
  module V1
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session

      @current_user

      def authenticate_user!
      end
    end
  end
end
