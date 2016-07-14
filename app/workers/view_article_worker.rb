# frozen_string_literal: true
class ViewArticleWorker
  include Sidekiq::Worker

  # rubocop:disable Metrics/MethodLength
  def perform(viewer_id, faver_id, story_id, url)
    fave = CUserFave.new(c_user_id: Cequel.uuid(faver_id),
                         id: Cequel.uuid(story_id))
    event_label = ''

    if faver_id && story_id
      fave.increment_view
      event_label = "#{faver_id}/#{story_id}/"
    end

    event_label += url.to_s

    GoogleAnalyticsApi.new.event(
      'article',
      faver_id,
      event_label,
      0,
      viewer_id
    )
  end
end
