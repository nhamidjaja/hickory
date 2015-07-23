class FController < ApplicationController
  before_action :authenticate_user!

  def index
    canon_url = Fave::Url.new(params[:url]).canon

    # Move everything below to worker
    fave_url(canon_url)

    redirect_to root_path
  end

  private

  def fave_url(canon_url)
    article = get_article(canon_url)
    faved = get_faved(canon_url)

    faved.save!

    UserFave.create(user_id: current_user.id.to_s,
                    id: faved.id,
                    content_url: article.url,
                    headline: article.title,
                    image_url: article.image_url,
                    published_at: article.published_at)
  end

  def get_article(canon_url)
    Content.where(url: canon_url).first || Content.new(url: canon_url)
  end

  def get_faved(canon_url)
    UserFaveUrl.where(user_id: current_user.id.to_s,
                      content_url: canon_url).first ||
      UserFaveUrl.new(user_id: current_user.id.to_s,
                      content_url: canon_url,
                      id: Cequel.uuid(Time.zone.now))
  end
end
