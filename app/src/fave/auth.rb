module Fave
  class Auth
    # read-only attributes
    attr_reader :email, :uid, :provider, :token

    def initialize(user_email, user_provider, user_uid, user_token)
      @email = user_email
      @provider = user_provider
      @uid = user_uid
      @token = user_token
    end

    def self.from_omniauth(auth)
      Auth.new(auth['info']['email'], auth['provider'], auth['uid'], auth['credentials']['token'])
    end

    def self.from_facebook(fb_user)
      Auth.new(fb_user.email, 'facebook', fb_user.id, fb_user.access_token)
    end
  end
end
