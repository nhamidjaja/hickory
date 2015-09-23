class RegistrationsController < Devise::RegistrationsController
  def create
    super

    return unless resource.persisted?

    UserMailer.welcome(resource).deliver_later
    GetFriendsFromFacebookWorker.perform_async(resource)
  end

  private

  def build_resource(*args)
    super

    return unless session[:omniauth]

    resource.apply_third_party_auth(
      Fave::Auth.from_omniauth(session[:omniauth])
    )
    resource.valid?
  end
end
