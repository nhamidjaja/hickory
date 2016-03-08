class ViewArticleWorker
  include Sidekiq::Worker

  def perform(viewer_id, faver_id, attribution_id)
    CUserFave.new(c_user_id: Cequel.uuid(faver_id),
                  id: Cequel.uuid(attribution_id))
             .increment_view
  end
end
