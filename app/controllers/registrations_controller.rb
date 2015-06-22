class RegistrationsController < Devise::RegistrationsController

  private

  def build_resource(*args)
    super

    if session[:omniauth]  
      self.resource.apply_omniauth(session[:omniauth])  
      self.resource.valid?
    end  
  end  
end
