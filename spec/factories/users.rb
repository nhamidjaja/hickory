FactoryGirl.define do
  factory :user do
    email                       { Faker::Internet.email }
    username                    { Faker::Internet.user_name }
    password 'password01'
    password_confirmation 'password01'
  end
end
