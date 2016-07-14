# frozen_string_literal: true
module Fave
  # Adapter class for third party authentications
  class Auth
    # read-only attributes
    attr_reader :email, :uid, :provider, :token, :full_name, :picture

    # rubocop:disable Metrics/ParameterLists
    def initialize(user_email, user_provider, user_uid, user_token,
                   user_full_name, user_picture)

      @email = user_email
      @provider = user_provider
      @uid = user_uid
      @token = user_token
      @full_name = user_full_name
      @picture = user_picture
    end

    def self.from_omniauth(auth)
      Auth.new(auth['info']['email'],
               auth['provider'],
               auth['uid'],
               auth['credentials']['token'],
               auth['info']['name'],
               auth['info']['image'])
    end

    def self.from_koala(koala_user, token)
      Auth.new(koala_user['email'], 'facebook', koala_user['id'], token,
               koala_user['name'], koala_user['picture']['data']['url'])
    end
  end
end
