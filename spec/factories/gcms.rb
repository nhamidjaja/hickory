FactoryGirl.define do
  factory :gcm do
    association :user, factory: :user
    registration_token 'MyString'
  end
end
