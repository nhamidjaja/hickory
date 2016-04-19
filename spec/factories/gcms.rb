FactoryGirl.define do
  factory :gcm do
    association :user, factory: :user
    registration_id "MyString"
  end
end
