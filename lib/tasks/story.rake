namespace :story do
  task anonymous: :environment do
    Rake::Task['story:anonymous'].reenable

    story = OpenStory.order('faved_at DESC').first
    faver = story.faver

    print "Begin story:anonymous broadcast"
    print "#{story.faver.username}\n"
    print "#{story.content_url}\n"
    print "#{story.title}\n"

    Gcm.where(user_id: nil).each do |g|
      print "."
      BroadcastFaveWorker.perform_async(
        g.registration_token,
        faver.username,
        story.title
        )
    end
    print "\n"
  end

  task registered: :environment do
    Rake::Task['story:registered'].reenable

    print "Begin story:registered broadcast"
    Gcm.where.not(user_id: nil).each do |g|
      print "."
      BroadcastUserStoryWorker.perform_async(
        g.user_id,
        g.registration_token
        )
    end
    print "\n"
  end
end