module A
  module V1
    module Me
      class FaveUrlsController < ApplicationController
        def index
          canon_url = Fave::Url.new(params[:url]).canon

          @fave_url = current_user.in_cassandra
                      .c_user_fave_urls.consistency(:one)
                      .find_by_content_url(canon_url)

          fail Errors::NotFound unless @fave_url
        end
      end
    end
  end
end
