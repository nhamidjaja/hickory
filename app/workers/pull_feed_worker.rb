class PullFeedWorker
  include Sidekiq::Worker
  sidekiq_options queue: :pull_feed

  def perform(feeder_id)
    feeder = Feeder.find(feeder_id)
    feed = Feedjira::Feed.fetch_and_parse(feeder.feed_url)

    feeder.top_articles.destroy_all

    articles = Array.new

    feed.entries.each do |entry|
      articles.push(
        TopArticle.new(content_url: Fave::Url.new(entry.url).canon,
          title: entry.title,
          image_url: entry.image,
          published_at: entry.published
          )
        )
    end

    feeder.top_articles << articles

    PullFeedWorker.perform_in(5.minutes, feeder_id)
  end
end
