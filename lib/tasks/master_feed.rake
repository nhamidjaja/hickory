namespace :master_feed do
  task refresh: :environment do
    Sidekiq::Queue.new('pull_feed').clear

    Feeder.all.each do |f|
      PullFeedWorker.perform_async(f.id.to_s)
    end
  end
end
