class FaveWorker
  include Sidekiq::Worker
  sidekiq_options queue: :fave

  def perform(url, user)
    canon_url = Fave::Url.new(url).canon

    fave_url(canon_url, user)
  end

  def fave_url(canon_url, user)
    article = get_article(canon_url)
    faved = get_faved(canon_url, user)

    faved.save!

    CUserFave.create(c_user_id: user.id.to_s,
                     id: faved.id,
                     content_url: article.url,
                     headline: article.title,
                     image_url: article.image_url,
                     published_at: article.published_at)
  end

  def get_article(canon_url)
    Content.where(url: canon_url).first || Content.new(url: canon_url)
  end

  def get_faved(canon_url, user)
    CUserFaveUrl.where(c_user_id: user.id.to_s,
                       content_url: canon_url).first ||
      CUserFaveUrl.new(c_user_id: user.id.to_s,
                       content_url: canon_url,
                       id: Cequel.uuid(Time.zone.now))
  end
end
