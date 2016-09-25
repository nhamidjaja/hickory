# frozen_string_literal: true
class NotifyNewFollowerWorker
  include CloudMessageable
  include Sidekiq::Worker
  sidekiq_options queue: :low

  # rubocop:disable Metrics/MethodLength
  def perform(registration_token, target_id, target_username,
              target_profile_picture_url)
    @token = registration_token
    fcm = FCM.new(Figaro.env.fcm_server_key!)

    options = { data: {
      type: 'new_follower',
      user_id: target_id,
      user_username: target_username,
      user_profile_picture_url: target_profile_picture_url
    } }
    response = fcm.send([@token], options)

    token_upkeep(response[:not_registered_ids].first,
                 response[:canonical_ids].first)

    raise response[:response] unless response[:response].eql?('success')
  end
end
