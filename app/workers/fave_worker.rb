class FaveWorker
  include Sidekiq::Worker

  # rubocop:disable Metrics/ParameterLists
  def perform(user_id, url, faved_time,
              title, image_url, published_at, open_story)
    canon_url = Fave::Url.new(url).canon
    content = get_content(canon_url, title, image_url, published_at)
    faver = CUser.new(id: user_id)
    faved_at = Time.zone.parse(faved_time).utc

    fave = faver.fave(content, faved_at)

    save_as_open_story(fave) if open_story

    propagate_to_followers(faver, fave)
  end

  private

  def get_content(url, title, image_url, published_at)
    Content.new(
      url: url,
      title: title,
      image_url: image_url,
      published_at: published_at || Time.zone.now
    )
  end

  def save_as_open_story(fave)
    OpenStory.create(id: fave.id.to_s,
                     faver_id: fave.c_user_id.to_s,
                     content_url: fave.content_url,
                     title: fave.title,
                     image_url: fave.image_url,
                     published_at: fave.published_at,
                     faved_at: fave.faved_at)
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
