FactoryGirl.define do
  factory :c_user_fave_url do
    association :c_user, factory: :c_user, strategy: :build
    content_url { 'http://example.com/abc' }
    id { Cequel.uuid(Time.zone.now) }
  end
end
