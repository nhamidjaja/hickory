module A
  module V1
    module Me
      class FriendsController < A::V1::ApplicationController
        def index
          @friends = fetch_friends

          return if params[:last_id]

          newest = User.select(:id).order('created_at DESC').limit(5)
          mapped = newest.map { |f| Friend.new(id: f.id.to_s) }
          @friends.unshift(*mapped).uniq

          # featured = FeaturedUser.select(:user_id).order('RANDOM()').limit(1)
          # converted = featured.map { |f| Friend.new(id: f.user_id.to_s) }
          # @friends.unshift(*converted)
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
