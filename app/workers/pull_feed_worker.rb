class PullFeedWorker
  include Sidekiq::Worker
  sidekiq_options queue: :pull_feed

  def perform(feeder_id)
    feeder = Feeder.find(feeder_id)
    feed = Feedjira::Feed.fetch_and_parse(feeder.feed_url)

    feed.entries.each do |entry|
      MasterFeed.create(content_url: entry.url,
                        headline: entry.title,
                        image_url: entry.image,
                        published_at: entry.published)
    end

    PullFeedWorker.perform_in(5.minutes, feeder_id)
  end
end
