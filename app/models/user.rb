class User < ActiveRecord::Base
  # include ActiveUUID::UUID

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  validates :username,
            uniqueness: true,
            format: { with: /\A[a-z0-9_.]{1,15}\z/ }

  def self.from_omniauth(auth)
    user = find_by_email(auth['info']['email']) ||
           find_by(provider: auth['provider'], uid: auth['uid']) ||
           User.new
    user.apply_omniauth(auth)

    user
  end

  def apply_omniauth(auth)
    self.provider = auth['provider']
    self.uid = auth['uid']
    self.email = auth['info']['email'] if self.new_record?
    self.omniauth_token = auth['credentials']['token']
  end

  def valid_token?(token)
    return true if omniauth_token.eql?(token)

    me = FbGraph2::User.me(omniauth_token)
    begin
      fb_user = me.fetch
    rescue FbGraph2::Exception::InvalidToken
      return false
    end

    omniauth_token = fb_user.access_token
    true
  end

  protected

  def password_required?
    (provider.blank? || uid.blank? || !password.blank?) && super
  end
end
