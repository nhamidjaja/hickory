json.friends(@friends) do |friend|
  f = User.find_by_id(friend.id)

  json.id f.id.to_s
  json.username f.username
  json.full_name f.full_name
end

# json.stories(@stories) do |story|
#   json.id           story.id.to_s
#   json.content_url  story.content_url
#   json.title        story.title
#   json.image_url    story.image_url
#   json.published_at story.published_at.to_i
#   json.faved_at     story.faved_at.to_i

#   faver = User.find_by_id(story.faver_id)
#   json.faver(faver, :id, :username)
# end
