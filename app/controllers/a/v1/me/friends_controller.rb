module A
  module V1
    module Me
      class FriendsController < A::V1::ApplicationController
        def index
          @friends = fetch_friends

          return if params[:last_id]

          featured_user = FeaturedUser.order('RANDOM()').first
          return unless featured_user

          @friends.unshift(Friend.new(id: featured_user.user_id.to_s))
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
end
