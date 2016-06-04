module A
  module V1
    module Me
      class StoriesController < A::V1::ApplicationController
        skip_before_action :authenticate_user_from_token!,
                           unless: -> { request.headers['X-Email'].present? }

        # Not using Null Object Pattern because of two different databases
        def index
          stories = current_user ? fetch_user_stories : fetch_open_stories
          @stories = stories.limit(20)
        end

        private

        def fetch_user_stories
          stories = current_user.in_cassandra.stories

          if params[:last_id]
            stories = stories.before(Cequel.uuid(params[:last_id]))
          end

          stories
        end

        # rubocop:disable Rails/Date
        # Because #to_time is used on Timeuuid
        def fetch_open_stories
          stories = OpenStory.all.order('faved_at DESC')

          if params[:last_id]
            stories = stories.where(
              'faved_at < ?', Cequel.uuid(params[:last_id]).to_time
            )
          end

          stories
        end
      end
    end
  end
end
