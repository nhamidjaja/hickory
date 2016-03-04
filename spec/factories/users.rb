FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::Internet.user_name(nil, %w(_)) }
    password 'password01'
    password_confirmation 'password01'
    full_name { Faker::Name.name }
    sign_in_count 0
  end
end
