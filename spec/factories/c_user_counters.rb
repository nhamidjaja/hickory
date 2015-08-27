FactoryGirl.define do
  factory :c_user_counter do
    association :c_user, factory: :c_user, strategy: :build
  end
end
