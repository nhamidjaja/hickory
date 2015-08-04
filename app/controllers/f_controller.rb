class FController < ApplicationController
  before_action :authenticate_user!

  def index
    FaveWorker.perform_async(current_user.id.to_s, params[:url])
  end
end
