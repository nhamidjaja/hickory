module A
  module V1
    module Me
      # TODO: Deprecate this into /people
      class FriendsController < A::V1::ApplicationController
        skip_before_action :authenticate_user_from_token!,
                           unless: -> { request.headers['X-Email'].present? }

        def index
          @friends = current_user ? fetch_friends : []

          return if params[:last_id]

          latest = fetch_latest_users
          mapped = latest.map { |f| Friend.new(id: f.id.to_s) }
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

        def fetch_latest_users
          latest = User.order('updated_at DESC').limit(5).to_a
          latest.delete(current_user)
          latest
        end
      end
    end
  end
end
