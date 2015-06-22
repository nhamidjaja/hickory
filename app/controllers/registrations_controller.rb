class RegistrationsController < Devise::RegistrationsController
  private

  def build_resource(*args)
    super

    return unless session[:omniauth]
    resource.apply_omniauth(session[:omniauth])
    resource.valid?
  end
end
