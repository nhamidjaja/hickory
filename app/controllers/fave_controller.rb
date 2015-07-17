class FaveController < ApplicationController
  before_action :authenticate_user!

  def index
    url = Fave::Url.new(params[:url])

    # Move everything below to worker
    article = MasterFeed.where(content_url: url.canon).first || MasterFeed.new

    fave_url(url, article)

    redirect_to root_path
  end

  private

  def fave_url(url, article)
    faved = UserFaveUrl.where(user_id: current_user.id.to_s, content_url: url.canon).first

    timeuuid = Cequel.uuid(Time.zone.now)

    if faved
      timeuuid = faved.id
    else
      UserFaveUrl.create(user_id: current_user.id.to_s, content_url: url.canon, id: timeuuid)
    end

    UserFave.create(user_id: current_user.id.to_s,
                    id: timeuuid,
                    content_url: url.canon,
                    headline: article.headline,
                    image_url: article.image_url,
                    published_at: article.published_at)
  end
end
