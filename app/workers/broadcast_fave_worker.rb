class BroadcastFaveWorker
  include Sidekiq::Worker

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def perform(registration_token, username, article_title)
    fcm = FCM.new(Figaro.env.fcm_server_key!)

    options = { notification: {
      icon: 'ic_notify',
      sound: 'default',
      color: '#FF9800',
      title: "@#{username}",
      body: article_title
    } }
    response = fcm.send([registration_token], options)

    destroy_unregistered_token(response[:not_registered_ids].first)
    update_canonical_token(registration_token, response[:canonical_ids].first)

    raise response[:response] unless response[:response].eql?('success')

    track_event(options)
  end

  private

  def destroy_unregistered_token(unregistered)
    Gcm.where(registration_token: unregistered).destroy_all if unregistered
  end

  def update_canonical_token(original, canonical)
    if canonical
      gcm = Gcm.find(original)
      gcm.update_attributes!(registration_token: canonical)
    end
  end

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
