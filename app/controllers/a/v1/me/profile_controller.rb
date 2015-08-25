module A
  module V1
    module Me
      class ProfileController < A::V1::ApplicationController
        def index; end

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
