module A
  module V1
    class FeaturedUsersController < ApplicationController
      def index
        @featured_users = User.joins(:featured_user).limit(20)
      end
    end
  end
end
