# frozen_string_literal: true
module A
  module V1
    class FeaturedUsersController < ApplicationController
      def index
        @featured_users = User.joins(:featured_user)
                              .order('priority ASC')
                              .limit(50).to_a

        return if current_user

        @featured_users = @featured_users.delete_if do |f|
          current_user.in_cassandra.following?(f)
        end
      end
    end
  end
end
