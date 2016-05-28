class UnfollowUserWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(user_id, target_id)
    user = CUser.new(id: user_id)
    target = CUser.new(id: target_id)

    user.unfollow(target)

    GoogleAnalyticsApi.new.event('user_followers',
                                 target_id,
                                 user_id,
                                 -1,
                                 user_id)

    remove_target_faves(user, target)
  end

  def remove_target_faves(user, target)
    target.c_user_faves.each do |fave|
      RemoveStoryWorker.perform_async(
        user.id.to_s,
        fave.id.to_s
      )
    end
  end
end
