# frozen_string_literal: true
FactoryGirl.define do
  factory :c_user do
    id { Cequel.uuid(SecureRandom.uuid.to_s) }
  end
end
