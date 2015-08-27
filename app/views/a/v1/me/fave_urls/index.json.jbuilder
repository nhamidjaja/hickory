json.fave_url do
  json.content_url @fave_url.content_url
  json.faved_at @fave_url.faved_at.to_i
end
