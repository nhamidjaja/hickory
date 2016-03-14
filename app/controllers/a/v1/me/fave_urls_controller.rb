module A
  module V1
    module Me
      class FaveUrlsController < ApplicationController
        def index
          canon_url = Fave::Url.new(params[:url]).canon

          count_view

          @fave_url = current_user
                      .in_cassandra.c_user_fave_urls.consistency(:one)
                      .find_by_content_url(canon_url)

          if @fave_url
            render
            return
          end

          render json: { fave_url: nil }
        end

        private

        def count_view
          if count_as_view?
            ViewArticleWorker.perform_async(current_user.id.to_s,
                                            params[:attribution_id],
                                            params[:story_id])
          end
        end

        def count_as_view?
          params[:attribution_id].present? &&
            !params[:attribution_id].eql?(current_user.id.to_s)
        end
      end
    end
  end
end
