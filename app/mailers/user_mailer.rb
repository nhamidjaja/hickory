# frozen_string_literal: true
class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Selamat Datang ke Fave, '\
     + @user.username)
  end

  def tcc_announce(user)
    @user = user
    mail(to: @user.email, subject: 'Baca berita bisa dapat hadiah dengan '\
     'aplikasi Flyer')
  end
end
