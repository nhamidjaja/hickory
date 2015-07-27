FactoryGirl.define do
  factory :user_friend do
    user { FactoryGirl.create(:user) }
    provider 'facebook'
    uid 'MyString'
  end
end
