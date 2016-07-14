# frozen_string_literal: true
FactoryGirl.define do
  factory :feeder do
    feed_url { Faker::Internet.url }
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
  end
end
