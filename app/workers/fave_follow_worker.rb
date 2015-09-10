class FaveFollowWorker
  include Sidekiq::Worker

  # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
  def perform(user_id, fave_user_id,
    fave_id, content_url, title, image_url, published_at, faved_at)
    c_user = CUser.new(id: user_id)

    id = Cequel.uuid(fave_id)
    c_user.following_feeds.new(
      id: id.to_s,
      faver_id: fave_user_id,
      content_url: content_url,
      title: title,
      image_url: image_url,
      published_at: published_at.blank? ? nil : published_at,
      faved_at: faved_at
    ).save!(consistency: :any)
  end
end
