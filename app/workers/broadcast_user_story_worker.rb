class BroadcastUserStoryWorker
  include Sidekiq::Worker

  def perform(user_id, registration_token)
    user = User.find(user_id)
    story = user.in_cassandra.stories.first

    if story
      faver = story.faver

      BroadcastFaveWorker.perform_async(
        registration_token,
        faver.username,
        story.title
      )
    end
  end
end
