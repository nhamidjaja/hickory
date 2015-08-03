module A
  module V1
    class FaveController < ApplicationController
      respond_to :json

      def index
        FaveWorker.perform_async(current_user.id, params['url'])
      end
    end
  end
end
