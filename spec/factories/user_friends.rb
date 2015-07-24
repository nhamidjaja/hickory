FactoryGirl.define do
  factory :user_friend do
    user { FactoryGirl.create(:user) }
    provider "MyString"
    uid "MyString"
  end

end
