# frozen_string_literal: true
class RemoveStoryWorker
  include Sidekiq::Worker

  # Tested with users_requests_spec.rb
  def perform(user_id, story_id)
    c_user = CUser.new(id: user_id)
    id = Cequel.uuid(story_id)

    c_user.stories.where(
      id: id
    ).destroy_all
  end
end
