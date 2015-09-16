class FaveWorker
  include Sidekiq::Worker

  def perform(user_id, url, faved_time)
    canon_url = Fave::Url.new(url).canon

    content = Content.find_or_initialize_by(url: canon_url)

    faver = CUser.new(id: user_id)
    faved_at = Time.zone.parse(faved_time).utc
    fave = faver.fave(content, faved_at)

    propagate_to_followers(faver, fave)
  end

  private

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
