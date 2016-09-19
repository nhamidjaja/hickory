# frozen_string_literal: true
class BroadcastFaveWorker
  include Sidekiq::Worker
  include CloudMessageable

  # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
  def perform(registration_token, faver_id, username, id, url, title, image_url)
    @token = registration_token
    fcm = FCM.new(Figaro.env.fcm_server_key!)

    options = { data: {
      type: 'story',
      faver_id: faver_id,
      faver_username: username,
      story_id: id,
      story_url: url,
      story_title: title,
      story_image_url: image_url
    } }
    response = fcm.send([@token], options)

    token_upkeep(response[:not_registered_ids].first,
                 response[:canonical_ids].first)

    raise response[:response] unless response[:response].eql?('success')

    # track_event(options)
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
