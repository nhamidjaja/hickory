class BroadcastFaveWorker
  include Sidekiq::Worker

  def perform(registration_token, username, article_title)
    fcm = FCM.new(Figaro.env.fcm_server_key!)

    options = { notification: {
      icon: 'ic_notify',
      sound: 'default',
      body: "@#{username} faved '#{article_title}'"
    } }
    response = fcm.send([registration_token], options)

    destroy_unregistered_token(response[:not_registered_ids].first)
    update_canonical_token(registration_token, response[:canonical_ids].first)

    raise response[:response] unless response[:response].eql?('success')
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
end
