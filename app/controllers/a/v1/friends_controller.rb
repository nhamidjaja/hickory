# frozen_string_literal: true
module A
  module V1
    class FriendsController < ApplicationController
      def index
        @friends = []

        @friends = fetch_friends if current_user

        render 'a/v1/me/friends/index.json'
      end

      private

      def fetch_friends
        friends = current_user.in_cassandra.friends
        if params[:last_id]
          friends = friends.after(Cequel.uuid(params[:last_id]))
        end
        friends.limit(20).to_a
      end
    end
  end
end
