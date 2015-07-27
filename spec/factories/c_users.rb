FactoryGirl.define do
  factory :c_user do
    id { FactoryGirl.create(:user).id.to_s }
  end
end
