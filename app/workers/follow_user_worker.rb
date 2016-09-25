# frozen_string_literal: true
class FollowUserWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high

  def perform(user_id, target_id)
    @user = User.find(user_id)
    @target = User.find(target_id)

    @user.in_cassandra.follow(@target.in_cassandra)

    GoogleAnalyticsApi.new.event('user_followers',
                                 target_id,
                                 user_id,
                                 1,
                                 user_id)

    forward_faves_to_user_timeline

    notify_target
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def forward_faves_to_user_timeline
    @target.in_cassandra.c_user_faves.each do |fave|
      StoryWorker.perform_async(
        @user.id.to_s,
        @target.id.to_s,
        fave.id.to_s,
        fave.content_url,
        fave.title,
        fave.image_url,
        fave.published_at.to_s,
        fave.faved_at.to_s
      )
    end
  end

  def notify_target
    @target.gcms.each do |g|
      NotifyNewFollowerWorker.perform_async(
        g.registration_token,
        @user.id.to_s,
        @user.username,
        @user.profile_picture_url
      )
    end
  end
end
