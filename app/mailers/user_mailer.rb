class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to Flyer')
  end

  def tcc_announce(user)
    @user = user
    mail(to: @user.email, subject: 'Baca berita bisa dapat hadiah dengan '\
     'aplikasi Flyer')
  end
end
