# top articles
3.times do
  feeder = FactoryGirl.create(:feeder)

  rand(9).times do
    FactoryGirl.create(:top_article, feeder: feeder)
  end
end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
