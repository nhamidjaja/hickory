class FaveWorker
  include Sidekiq::Worker

  def perform(user_id, url)
    canon_url = Fave::Url.new(url).canon

    content = Content.find_or_initialize_by(url: canon_url)

    fave(user_id, content)
  end

  private

  def fave(user_id, content)  # rubocop:disable Metrics/MethodLength
    fave_url = CUserFaveUrl.find_or_initialize_by(
      c_user_id: user_id, content_url: content.url) do |f|
      f.id = Cequel.uuid(Time.zone.now)
    end
    fave_url.save!(consistency: :any)

    CUserFave.new(c_user_id: user_id,
                  id: fave_url.id,
                  content_url: content.url,
                  title: content.title,
                  image_url: content.image_url,
                  published_at: content.published_at)
      .save!(consistency: :any)
  end
end
