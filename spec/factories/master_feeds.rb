FactoryGirl.define do
  factory :master_feed do
    content_url { Faker::Internet.url }
    headline { Faker::Lorem.sentence }
    image_url { 'http://tryflyer.com/image.png' }
    published_at { Time.zone.now }
  end
end
