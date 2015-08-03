module ControllerMacros
  # def login_admin
  #   before(:each) do
  #     @request.env["devise.mapping"] = Devise.mappings[:admin]
  #     sign_in FactoryGirl.create(:admin) # Using factory girl as an example
  #   end
  # end

  def login_user
    let(:current_user) { FactoryGirl.create(:user) }
    before(:each) do
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in current_user
    end
  end
end
