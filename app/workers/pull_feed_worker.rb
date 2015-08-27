class PullFeedWorker
  include Sidekiq::Worker
  sidekiq_options queue: :pull_feed

  def perform(feeder_id)
    feeder = Feeder.find(feeder_id)
    feed = Feedjira::Feed.fetch_and_parse(feeder.feed_url)

    feeder.top_articles.destroy_all

    feeder.top_articles << populate_articles(feed)

    PullFeedWorker.perform_in(5.minutes, feeder_id)
  end

  private

  def populate_articles(feed)
    articles = []
    feed.entries.each do |entry|
      articles.push(
        TopArticle.new(
          content_url: Fave::Url.new(entry.url).canon,
          title: entry.title, image_url: entry.image,
          published_at: entry.published))

      update_content(entry)
    end

    articles
  end

  def update_content(entry)
    Content.new(
      url: Fave::Url.new(entry.url).canon,
      title: entry.title, image_url: entry.image,
      published_at: entry.published
    ).save!(consistency: :any)
  end
end
