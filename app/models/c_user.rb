# User representation in cassandra
class CUser
  include Cequel::Record

  key :id, :uuid

  has_many :c_user_faves, class_name: 'CUserFave'
  has_many :c_user_fave_urls
  has_many :followings
  has_many :followers

  validates :id, presence: true

  def fave(content)
    save_faves(content)

    increment_faves_counter

    true
  end

  private

  def save_faves(content)  # rubocop:disable Metrics/MethodLength
    fave_id = Cequel.uuid(Time.zone.now)

    CUserFave.new(
      c_user_id: id,
      id: fave_id,
      content_url: content.url,
      title: content.title,
      image_url: content.image_url,
      published_at: content.published_at
    ).save!(consistency: :any)

    CUserFaveUrl.new(
      c_user_id: id,
      content_url: content.url,
      id: fave_id
    ).save!(consistency: :any)
  end

  def increment_faves_counter
    counter = Cequel::Metal::DataSet
              .new(:c_user_counters, CUserCounter.connection)
              .consistency(:one)
    counter.where(c_user_id: Cequel.uuid(id.to_s)).increment(faves: 1)
  end
end
