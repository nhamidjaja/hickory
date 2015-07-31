module A
  module V1
    class FaveController < ApplicationController
      respond_to :json

      def index
        FaveWorker.perform_async(params['url'], current_user)
      end
    end
  end
end
