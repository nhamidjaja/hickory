# frozen_string_literal: true
class FollowUserWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(user_id, target_id)
    user = CUser.new(id: user_id)
    target = CUser.new(id: target_id)

    user.follow(target)

    GoogleAnalyticsApi.new.event('user_followers',
                                 target_id,
                                 user_id,
                                 1,
                                 user_id)

    collect_target_faves(user, target)
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def collect_target_faves(user, target)
    target.c_user_faves.each do |fave|
      StoryWorker.perform_async(
        user.id.to_s,
        target.id.to_s,
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
