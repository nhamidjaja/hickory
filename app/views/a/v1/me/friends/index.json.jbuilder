json.friends(@friends) do |friend|
  f = User.find_by_id(friend.id)

  json.id f.id.to_s
  json.username f.username
  json.full_name f.full_name
end
