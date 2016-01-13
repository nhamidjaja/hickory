module Fave
  # Adapter class for third party authentications
  class Auth
    # read-only attributes
    attr_reader :email, :uid, :provider, :token, :full_name

    def initialize(user_email, user_provider, user_uid, user_token,
                   user_full_name = nil)

      @email = user_email
      @provider = user_provider
      @uid = user_uid
      @token = user_token
      @full_name = user_full_name
    end

    def self.from_omniauth(auth)
      Auth.new(auth['info']['email'],
               auth['provider'],
               auth['uid'],
               auth['credentials']['token'],
               auth['info']['name']
              )
    end

    def self.from_facebook(fb_user)
      Auth.new(fb_user.email, 'facebook', fb_user.id, fb_user.access_token,
               fb_user.name)
    end

    def self.from_koala(koala_user, token)
      Auth.new(koala_user['email'], 'facebook', koala_user['id'], token,
               koala_user['name'])
    end
  end
end
