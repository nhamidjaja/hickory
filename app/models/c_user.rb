# User representation in cassandra
class CUser
  include Cequel::Record

  key :id, :uuid

  has_many :c_user_faves, class_name: 'CUserFave'
  has_many :c_user_fave_urls

  validates :id, presence: true

  def fave!(content, opts = {})
    options = opts.present? ? opts : { consistency: :any }

    fave_url = CUserFaveUrl.find_or_initialize_by(
      c_user_id: id,
      content_url: content.url
    ) do |f|
      f.id = Cequel.uuid(Time.zone.now)
      f
    end

    if fave_url.new_record?
      fave_url.save!(options)

      CUserFave.new(c_user_id: id,
                    id: fave_url.id,
                    content_url: content.url,
                    title: content.title,
                    image_url: content.image_url,
                    published_at: content.published_at)
        .save!(options)
    end

    fave_url
  end
end
