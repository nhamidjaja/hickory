class FollowUserWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(user_id, target_id)
    user = User.find(user_id)
    target = User.find(target_id)

    user.follow(target)
  end
end
