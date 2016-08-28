# frozen_string_literal: true
module A
  module V1
    class FaveController < ApplicationController
      before_action :require_authentication!

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def index
        url = Fave::Url.new(params['url'])
        if url.valid?
          FaveWorker.perform_async(
            current_user.id.to_s,
            url.canon,
            Time.zone.now.utc.to_s,
            params['title'],
            params['image_url'],
            params['published_at'],
            current_user.open_stories
          )
        else
          render json: {
            errors: { message: 'Invalid URL' }
          }, status: 422
        end
      end
    end
  end
end
