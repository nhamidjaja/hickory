# This is a reverse implementation of CUserFaveUrl
class CUserFave
  include Cequel::Record

  belongs_to :c_user
  key :id, :timeuuid, order: :desc
  column :content_url, :text
  column :title, :text
  column :image_url, :text
  column :published_at, :timestamp
  column :faved_at, :timestamp

  timestamps

  validates :c_user_id, presence: true
  validates :id, presence: true
  validates :content_url, presence: true
  validates :faved_at, presence: true

  def counter
    @counter ||= FaveCounter.consistency(:one)
                            .find_or_initialize_by(
                              c_user_id: c_user_id,
                              id: id)

    @counter
  end

  def increment_view
    Cequel::Metal::DataSet
      .new(:fave_counters, FaveCounter.connection)
      .consistency(:one)
      .where(c_user_id: c_user_id, id: id)
      .increment(views: 1)
  end
end
