class RegistrationsController < Devise::RegistrationsController
  private

  def build_resource(*args)
    super

    if session[:omniauth]
      resource.apply_omniauth(session[:omniauth])
      resource.valid?
    end
  end
end
