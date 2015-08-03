class FController < ApplicationController
  before_action :authenticate_user!

  def index
    FaveWorker.perform_async(current_user.id, params[:url])

    redirect_to root_path
  end
end
