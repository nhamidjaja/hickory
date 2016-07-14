# frozen_string_literal: true
FactoryGirl.define do
  factory :c_user_fave, class: 'CUserFave' do
    association :c_user, factory: :c_user, strategy: :build
    id { Cequel.uuid(Time.zone.now) }
    content_url { Fave::Url.new(Faker::Internet.url).canon }
    title 'A headline'
    image_url 'http://example.com/image.jpg'
    published_at { Time.zone.now }
    faved_at { Time.zone.now }
  end
end
