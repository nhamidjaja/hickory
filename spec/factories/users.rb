FactoryGirl.define do
  factory :user do
    email                       { Faker::Internet.email }
    username 'abc'
    password 'password01'
    password_confirmation 'password01'
    uid '123123123123123'
  end
end
