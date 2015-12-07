class FController < ApplicationController
  before_action :authenticate_user!

  # rubocop:disable Metrics/AbcSize
  def index
    FaveWorker.perform_async(
      current_user.id.to_s,
      params[:url],
      Time.zone.now.to_s,
      params[:title],
      params[:image_url],
      params[:published_at]
    )

    render layout: false
  end

  def preview
    @content = Content.new(
      url: params[:url],
      title: params[:title],
      image_url: params[:image_url],
      published_at: params[:published_at]
    )
  end
end
