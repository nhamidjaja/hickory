json.stories(@stories) do |story|
  json.id           story.id.to_s
  json.content_url  story.content_url
  json.title        story.title
  json.image_url    story.image_url
  json.published_at story.published_at.to_i
  json.faved_at     story.faved_at.to_i
  json.views_count  story.counter.views
  faver = User.find_by_id(story.faver_id)
  json.faver(faver, :id, :username)
end
