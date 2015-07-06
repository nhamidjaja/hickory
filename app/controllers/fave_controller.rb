class FaveController < ApplicationController
  before_action :authenticate_user!

  def index
    url = Fave::Url.new(params[:url])

    # Move everything below to worker
    article = MasterFeed.where(content_url: url.canon).first || MasterFeed.new

    UserFave.create(user_id: current_user.id.to_s, content_url: url.canon,
                    headline: article.headline, header_image_url: article.header_image_url,
                    published_at: article.published_at)
  end
end
