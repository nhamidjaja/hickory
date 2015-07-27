# http://www.schneems.com/post/15948562424/speed-up-capybara-tests-with-devise/
module RequestMacros
  def sign_in_as_user
    before(:each) do
      user = FactoryGirl.create(:user)
      login_as(user, :scope => :user)
    end
  end
end
