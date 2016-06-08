module A
  module V1
    class FeaturedUsersController < ApplicationController
      before_action :require_authentication!

      def index
        @featured_users = User.joins(:featured_user).limit(20)
      end
    end
  end
end
