FactoryGirl.define do
  factory :top_article do
    content_url { Fave::Url.new(Faker::Internet.url).canon }
    feeder { FactoryGirl.create(:feeder) }
    title 'MyString'
    image_url 'MyString'
    published_at '2015-07-20 19:01:10'
  end
end
