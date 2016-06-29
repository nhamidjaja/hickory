json.user do
  json.id @user.id
  json.username @user.username
  json.full_name @user.full_name
  json.description @user.description
  json.profile_picture_url @user.profile_picture_url

  json.faves_count @user.counter.faves
  json.followers_count @user.counter.followers
  json.followings_count @user.counter.followings
  json.is_following @current_user.following?(@user)

  json.recent_faves(@recent_faves) do |fave|
    json.id                     fave.id.to_s
    json.content_url            fave.content_url
    json.title                  fave.title
    json.image_url              fave.image_url
    json.published_at           fave.published_at.to_i
    json.faved_at               fave.faved_at.to_i
    json.views_count            fave.counter.views
  end
end
