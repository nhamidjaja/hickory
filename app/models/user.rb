class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  validates :username, uniqueness: true, format: { with: /\A[a-z0-9_.]{1,15}\z/ }

  def self.from_omniauth(auth)
    user = find_by_email(auth['info']['email']) || find_by(provider: auth['provider'], uid: auth['uid']) || User.new
    user.apply_omniauth(auth)

    user
  end

  def apply_omniauth(auth)
    self.provider = auth['provider']
    self.uid = auth['uid']
    self.email = auth['info']['email']
    self.omniauth_token = auth['credentials']['token']
  end

  protected

  def password_required?
    (provider.blank? || uid.blank? || !password.blank?) && super
  end
end
