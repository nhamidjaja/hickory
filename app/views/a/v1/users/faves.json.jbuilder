json.faves(@faves) do |fave|
  json.id fave.id.to_s
  json.content_url fave.content_url
  json.following_fave_count fave.following_fave_count
  json.headline fave.headline
  json.image_url fave.image_url
  json.published_at fave.published_at
end
