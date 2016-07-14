# frozen_string_literal: true
class StoryWorker
  include Sidekiq::Worker

  # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
  def perform(user_id, target_id,
              fave_id, content_url, title, image_url, published_at, faved_at)
    c_user = CUser.new(id: user_id)
    id = Cequel.uuid(fave_id)

    c_user.stories.new(
      id: id,
      faver_id: target_id,
      content_url: content_url,
      title: title,
      image_url: image_url,
      published_at: Time.zone.parse(published_at),
      faved_at: faved_at
    ).save!(consistency: :any)
  end
end
