FactoryGirl.define do
  factory :c_user_counter do
    association :c_user, factory: :c_user, strategy: :build
    faves 0
    followers 0
    followings 0
  end
end
