FactoryGirl.define do
  factory :user do
    email                       { Faker::Internet.email }
    username 'abc'
    password 'password01'
    password_confirmation 'password01'
    full_name 'John Doe'
  end
end
