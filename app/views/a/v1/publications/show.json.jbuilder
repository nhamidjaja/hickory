json.publication do
  json.partial! 'feeder', publication: @publication
  json.is_subscribing @is_subscribing
  json.recent_entries @publication.top_articles.newest, partial: '/a/v1/top_articles/top_article', as: :article
end 