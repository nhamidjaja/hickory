FactoryGirl.define do
  factory :fave_counter do
    association :c_user, factory: :c_user, strategy: :build
    id { Cequel.uuid }
  end
end
