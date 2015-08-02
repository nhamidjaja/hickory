FactoryGirl.define do
  factory :c_user_fave, class: 'CUserFave' do
    association :c_user, factory: :c_user, strategy: :build
    id { Cequel.uuid(Time.zone.now) }
    content_url { 'http://example.com/abc' }
  end
end
