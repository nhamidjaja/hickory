namespace :story do
  task anonymous: :environment do
    Rake::Task['story:anonymous'].reenable

    story = OpenStory.order('faved_at DESC').first
    faver = story.faver

    Gcm.where(user_id: nil).each do |g|
      BroadcastFaveWorker.perform_async(
        g.token,
        faver.username,
        s.title
        )
    end
  end
end