module A
  module V1
    class FaveController < ApplicationController
      respond_to :json

      # rubocop:disable Metrics/AbcSize
      def index
        FaveWorker.perform_async(
          current_user.id.to_s,
          params['url'],
          Time.zone.now.utc.to_s,
          params['title'],
          params['image_url'],
          params['published_at'],
          current_user.open_stories
        )
      end
    end
  end
end
