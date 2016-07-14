# frozen_string_literal: true
class GoogleAnalyticsApi
  # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
  def event(category, action, label = nil, value = nil,
            user_id = nil, client_id = 'webapp')
    params = {
      v: 1,
      tid: Figaro.env.google_analytics_tracking_id!,
      cid: client_id,
      uid: user_id,
      t: 'event',
      ec: category,
      ea: action,
      el: label,
      ev: value
    }

    Typhoeus.post('www.google-analytics.com/collect',
                  params: params.compact, timeout: 5)
  end
end
