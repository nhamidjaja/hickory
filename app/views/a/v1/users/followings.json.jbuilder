json.followings(@followings) do |f|
  user = User.find(f.id.to_s)
  json.id               user.id.to_s
  json.username         user.username
  json.full_name        user.full_name
end