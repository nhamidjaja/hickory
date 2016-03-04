class ViewArticleWorker
  include Sidekiq::Worker

  def perform(user_id, attribution_id)
    CUserFave.new(c_user_id: Cequel.uuid(user_id), id: Cequel.uuid(attribution_id)).increment_view
  end
end
