class UserMailer < ApplicationMailer
  default from: 'phendy@readflyer.com'

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Read Flyer')
  end
end
