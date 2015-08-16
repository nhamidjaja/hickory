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

  def faves(last_id = nil, limit = nil)
    records = CUser.new(id: id.to_s).c_user_faves
    records = records.before(Cequel.uuid(last_id)) if last_id
    records = records.limit(limit) if limit

    records
  end

  def follow(target)
    already_following = following?(target)

    Following.new(c_user_id: id.to_s, id: target.id.to_s)
      .save!
    Follower.new(c_user_id: target.id.to_s, id: id.to_s)
      .save!

    increment_follow_counters(target) unless already_following
  end

  def following?(target)
    Following.where(c_user_id: id.to_s, id: target.id.to_s).any?
  end

  private

  def increment_follow_counters(target)
    counter = Cequel::Metal::DataSet
              .new(:c_user_counters, CUserCounter.connection)
              .consistency(:one)

    counter.where(c_user_id: Cequel.uuid(id.to_s)).increment(followings: 1)
    counter.where(c_user_id: Cequel.uuid(target.id.to_s))
      .increment(followers: 1)
  end

  protected

  def password_required?
    (provider.blank? || uid.blank? || !password.blank?) && super
  end
end
