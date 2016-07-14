# frozen_string_literal: true
FactoryGirl.define do
  factory :friend do
    association :c_user, factory: :c_user, strategy: :build
    id { Cequel.uuid }
  end
end
