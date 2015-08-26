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
    self.omniauth_token = auth.token
    self.email = auth.email if self.new_record?
    self.full_name = auth.full_name if self.new_record?
  end

  def ensure_authentication_token
    return unless authentication_token.blank?
    self.authentication_token = Devise.friendly_token
  end

  def in_cassandra
    CUser.new(id: id.to_s)
  end

  def faves(last_id = nil, limit = nil)
    records = in_cassandra.c_user_faves
    records = records.before(Cequel.uuid(last_id)) if last_id
    records = records.limit(limit) if limit

    records
  end

  def counter
    in_cassandra.c_user_counters.first
  end

  def following?(target)
    in_cassandra.following?(target.in_cassandra)
  end

  protected

  def password_required?
    (provider.blank? || uid.blank? || !password.blank?) && super
  end
end
