namespace :feeder do
  task refresh: :environment do
    print "Clearing pull_feed queue\n"
    Sidekiq::Queue.new('pull_feed').clear

    print "Clearing scheduled PullFeedWorker\n"
    r = Sidekiq::ScheduledSet.new
    jobs = r.select {|retri| retri.klass.eql?('PullFeedWorker') }
    jobs.each(&:delete)

    print "Queueing PullFeedWorker"
    Feeder.all.each do |f|
      PullFeedWorker.perform_async(f.id.to_s)
      print "."
    end
    print "\n"
  end
end
