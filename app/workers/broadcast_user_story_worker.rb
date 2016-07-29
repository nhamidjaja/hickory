# frozen_string_literal: true
class BroadcastUserStoryWorker
  include Sidekiq::Worker

  def perform(user_id, registration_token)
    user = User.find(user_id)
    return if user.active_recently?

    story = user.in_cassandra.stories.first
    return unless story

    faver = story.faver

    BroadcastFaveWorker.perform_async(
      registration_token,
      faver.username,
      story.title
    )
  end
end
