# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome(
      User.new(
        email: 'hello@readflyer.com',
        username: 'hello',
        full_name: 'Whatever Myname\'s'
      )
    )
  end
end
