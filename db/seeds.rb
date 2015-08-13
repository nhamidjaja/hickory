10.times do
  FactoryGirl.create(:user)
end

# top articles
f = Feeder.create(feed_url: 'http://liputan6.com/feed/rss2/', title: 'Liputan6 - General')
PullFeedWorker.new.perform(f.id.to_s)

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
