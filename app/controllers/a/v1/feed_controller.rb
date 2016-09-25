# frozen_string_literal: true
module A
  module V1
    class FeedController < A::V1::ApplicationController
      def index
        return [] unless current_user

        @entries = current_user.top_articles.order(published_at: :desc)

        last_published_at = params[:last_published_at]
        if last_published_at
          @entries = @entries.where(
            'published_at < ?',
            Time.zone.at(last_published_at.to_i).utc
          )
        end
        @entries = @entries.limit(30)
      end
    end
  end
end
