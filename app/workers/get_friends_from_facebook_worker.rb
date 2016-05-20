class GetFriendsFromFacebookWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)

    graph = Koala::Facebook::API.new(
      user.omniauth_token, Figaro.env.facebook_app_secret!
    )
    friends = graph.get_connections('me', 'friends')

    friends.each do |f|
      find_and_save_friend(user, f)
    end
  end

  private

  def find_and_save_friend(user, friend)
    local = User.find_by_provider_and_uid('facebook', friend['id'])

    return unless local

    Friend.new(c_user_id: user.id.to_s, id: local.id.to_s)
          .save!(consistency: :any)
    Friend.new(c_user_id: local.id.to_s, id: user.id.to_s)
          .save!(consistency: :any)
  end
end
