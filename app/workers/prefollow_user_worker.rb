# frozen_string_literal: true
class PrefollowUserWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(user_id)
    FeaturedUser.all.each do |f|
      FollowUserWorker.perform_async(user_id, f.user.id.to_s)
    end
  end
end
