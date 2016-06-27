class ViewArticleWorker
  include Sidekiq::Worker

  def perform(viewer_id, faver_id, story_id)
    CUserFave.new(c_user_id: Cequel.uuid(faver_id),
                  id: Cequel.uuid(story_id))
             .increment_view

    GoogleAnalyticsApi.new.event(
      'article',
      faver_id,
      "#{faver_id}/#{story_id}",
      1,
      viewer_id
    )
  end
end
