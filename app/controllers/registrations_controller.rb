class RegistrationsController < Devise::RegistrationsController
  def create
    super

    return unless resource.persisted?

    PrefollowUserWorker.perform_async(resource.id.to_s)
    UserMailer.welcome(resource).deliver_later
    GetFriendsFromFacebookWorker.perform_async(resource.id.to_s)
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
