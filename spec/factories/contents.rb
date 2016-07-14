# frozen_string_literal: true
FactoryGirl.define do
  factory :content do
    url { Faker::Internet.url }
  end
end
