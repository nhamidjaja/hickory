class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [ :facebook ]

  validates :username, uniqueness: true, format: { with: /\A[a-z0-9_.]{1,15}\z/ }

  def self.from_omniauth(auth)
    user = find_by_email(auth.info.email) || where(provider: auth.provider, uid: auth.uid).first || User.new
    user.provider = auth.provider
    user.uid = auth.uid
    user.email = auth.info.email
    user.omniauth_token = auth.credentials.token

    return user
  end
end
