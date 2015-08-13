FactoryGirl.define do
  factory :follower do
    association :c_user, factory: :c_user, strategy: :build
    id { FactoryGirl.build(:c_user).id }
  end

end
