# frozen_string_literal: true
class OmniauthCallbacksController < ApplicationController
  include Devise::Controllers::Rememberable

  def facebook
    omniauth = request.env['omniauth.auth']
    user = User.from_third_party_auth(Fave::Auth.from_omniauth(omniauth))

    if user.persisted? && user.save
      remember_me(user)
      sign_in_and_redirect(user, event: :authentication)
    else
      session[:omniauth] = omniauth.except('extra')
      redirect_to new_user_registration_path
    end
  end
end
