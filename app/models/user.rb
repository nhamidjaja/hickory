class User < ActiveRecord::Base
  include PgSearch

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  validates :username,
            uniqueness: true,
            format: { with: /\A[a-z0-9_.]{2,30}\z/ }

  before_save :ensure_authentication_token

  pg_search_scope :search_by_username,
                  against: :username,
                  using: {
                    tsearch: { prefix: true }
                  }

  def ensure_authentication_token
    return unless authentication_token.blank?
    self.authentication_token = Devise.friendly_token
  end

  def self.from_third_party_auth(auth)
    user = find_by_email(auth.email) ||
           find_by_provider_and_uid(auth.provider, auth.uid) ||
           User.new
    user.apply_third_party_auth(auth)

    user
  end

  def apply_third_party_auth(auth)
    self.provider = auth.provider
    self.uid = auth.uid
    self.email = auth.email if self.new_record?
    self.omniauth_token = auth.token
  end

  protected

  def password_required?
    (provider.blank? || uid.blank? || !password.blank?) && super
  end
end
