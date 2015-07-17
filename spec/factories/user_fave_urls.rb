FactoryGirl.define do
  factory :user_fave_url do
    user_id { FactoryGirl.create(:user).id.to_s }
    content_url { 'example.com/abc' }
    id { Cequel.uuid(Time.zone.now) }
  end

end
