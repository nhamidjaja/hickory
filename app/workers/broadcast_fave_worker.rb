# frozen_string_literal: true
class BroadcastFaveWorker
  include Sidekiq::Worker
  include CloudMessageable

  # rubocop:disable Metrics/MethodLength
  def perform(registration_token, username, article_title)
    @token = registration_token
    fcm = FCM.new(Figaro.env.fcm_server_key!)

    options = { notification: {
      icon: 'ic_notify',
      color: '#FF9800',
      title: "@#{username}",
      body: article_title
    } }
    response = fcm.send([@token], options)

    token_upkeep(response[:not_registered_ids].first,
                 response[:canonical_ids].first)

    raise response[:response] unless response[:response].eql?('success')

    track_event(options)
  end

  private

  def track_event(options)
    GoogleAnalyticsApi.new.event(
      'cloud_messaging',
      'broadcast_fave',
      options[:notification][:title],
      0,
      options[:notification][:body]
    )
  end
end
