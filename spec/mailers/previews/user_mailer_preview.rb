# frozen_string_literal: true
# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome(
      FactoryGirl.build(:user)
    )
  end

  def tcc_announce
    UserMailer.tcc_announce(
      FactoryGirl.build(:user)
    )
  end
end
