class UnfollowUserWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(user_id, target_id)
    user = CUser.new(id: user_id)
    target = CUser.new(id: target_id)

    user.unfollow(target)
  end
end
