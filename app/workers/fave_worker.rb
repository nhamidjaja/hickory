class FaveWorker
  include Sidekiq::Worker

  # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
  def perform(user_id, url, faved_time,
              title = nil, image_url = nil, published_at = nil)
    canon_url = Fave::Url.new(url).canon
    content = get_content(canon_url, title, image_url, published_at)
    faver = CUser.new(id: user_id)
    faved_at = Time.zone.parse(faved_time).utc
    fave = faver.fave(content, faved_at)

    propagate_to_followers(faver, fave)
  end

  private

  def get_content(url, title, image_url, published_at)
    if title || image_url || published_at
      return Content.new(
        url: url,
        title: title,
        image_url: image_url,
        published_at: Time.zone.parse(published_at).utc
      ).save!(consistency: :any)
    else
      return Content.find_or_initialize_by(url: url)
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def propagate_to_followers(faver, fave)
    faver.followers.each do |follower|
      StoryWorker.perform_async(
        follower.id.to_s,
        faver.id.to_s,
        fave.id.to_s,
        fave.content_url,
        fave.title,
        fave.image_url,
        fave.published_at.to_s,
        fave.faved_at.to_s
      )
    end
  end
end
