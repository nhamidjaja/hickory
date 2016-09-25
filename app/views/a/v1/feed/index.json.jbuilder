json.entries(@entries) do |entry|
  json.content_url entry.content_url
  json.title entry.title
  json.image_url entry.image_url
  json.published_at entry.published_at.to_i
end
