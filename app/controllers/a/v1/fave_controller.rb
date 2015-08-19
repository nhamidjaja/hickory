module A
  module V1
    class FaveController < ApplicationController
      respond_to :json

      def index
        FaveWorker.perform_async(
          current_user.id.to_s,
          params['url'],
          Time.zone.now.utc)
      end
    end
  end
end
