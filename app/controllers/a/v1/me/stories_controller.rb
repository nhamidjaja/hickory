module A
  module V1
    module Me
      class StoriesController < A::V1::ApplicationController
        def index
          @stories = current_user.in_cassandra.stories
          if params[:last_id]
            @stories = @stories.before(Cequel.uuid(params[:last_id]))
          end
          @stories = @stories.limit(20)
        end
      end
    end
  end
end
