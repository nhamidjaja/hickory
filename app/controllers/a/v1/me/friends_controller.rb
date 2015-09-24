module A
  module V1
    module Me
      class FriendsController < A::V1::ApplicationController
        def index
          @friends = current_user.in_cassandra.friends
          if params[:last_id]
            @friends = @friends.after(Cequel.uuid(params[:last_id]))
          end
          @friends = @friends.limit(20)
        end
      end
    end
  end
end
