json.top_articles(@top_articles) do |article|
  json.content_url article.content_url
  json.title article.title
  json.image_url article.image_url
  json.published_at article.published_at.to_i
end
