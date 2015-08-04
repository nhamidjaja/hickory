module A
  module V1
    class UsersController < A::V1::ApplicationController
      respond_to :json

      def show
        @user = User.find(params[:id])
      end

      def faves
        user = User.find(params[:id])
        @faves = CUser.new(id: user.id.to_s).c_user_faves
        @faves = @faves.before(Cequel.uuid(params[:last_id])) if params[:last_id]
        @faves = @faves.limit(10)
      end
    end
  end
end
