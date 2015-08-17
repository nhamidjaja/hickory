class FaveWorker
  include Sidekiq::Worker

  def perform(user_id, url)
    canon_url = Fave::Url.new(url).canon

    content = Content.find_or_initialize_by(url: canon_url)

    CUser.new(id: user_id).fave(content)
  end
end
