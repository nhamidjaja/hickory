FactoryGirl.define do
  factory :story_counter do
    association :c_user, factory: :c_user, strategy: :build
    story_id  { Cequel.uuid }
  end
end
