module A
  module V1
    module Me
      class ProfileController < A::V1::ApplicationController
        def index
          @user = current_user
          @recent_faves = @user.faves(nil, 20)
          render 'a/v1/users/show.json'
        end

        def create
          @user = current_user

          begin @user.update_attributes!(user_params)
                render
          rescue ActiveRecord::RecordInvalid => e
            render_unprocessable_entity(e)
          end
        end

        private

        def user_params
          params.require(:user).permit(:username, :full_name, :description)
        end
      end
    end
  end
end
