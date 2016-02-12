class ViewStoryWorker
  include Sidekiq::Worker

  def perform(user_id, story_id)
    increment_view_counter(user_id, story_id)
  end

  private

  def increment_view_counter(user_id, story_id)
    Cequel::Metal::DataSet
      .new(:fave_counters, FaveCounter.connection)
      .consistency(:one)
      .where(c_user_id: user_id, id: story_id)
      .increment(views: 1)
  end
end
