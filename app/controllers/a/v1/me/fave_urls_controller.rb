# frozen_string_literal: true
module A
  module V1
    module Me
      class FaveUrlsController < ApplicationController
        def index
          canon_url = Fave::Url.new(params[:url]).canon

          count_view(canon_url)

          render(json: { fave_url: nil }) && return unless current_user

          @fave_url = fetch_fave_url(canon_url)

          render && return if @fave_url

          render json: { fave_url: nil }
        end

        private

        def count_view(canon_url)
          return if view_as_self?

          viewer_id = current_user ? current_user.id : nil
          ViewArticleWorker.perform_async(viewer_id,
                                          params[:attribution_id],
                                          params[:story_id],
                                          canon_url)
        end

        def view_as_self?
          current_user &&
            params[:attribution_id].eql?(current_user.id.to_s)
        end

        def fetch_fave_url(canon_url)
          @fave_url = current_user
                      .in_cassandra.c_user_fave_urls.consistency(:one)
                      .find_by_content_url(canon_url)
        end
      end
    end
  end
end
