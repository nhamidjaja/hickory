# frozen_string_literal: true
FactoryGirl.define do
  factory :following do
    association :c_user, factory: :c_user, strategy: :build
    id { FactoryGirl.build(:c_user).id }
  end
end
