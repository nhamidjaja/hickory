FactoryGirl.define do
  factory :top_article do
    content_url { Fave::Url.new(Faker::Internet.url).canon }
    association :feeder, factory: :feeder, strategy: :build
    title { Faker::Lorem.sentence }
    image_url { Faker::Internet.url }
    published_at { Faker::Date.between(1.days.ago, Time.zone.today) }
  end
end
