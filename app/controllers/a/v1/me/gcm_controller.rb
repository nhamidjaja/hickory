module A
  module V1
    module Me
      class GcmController < A::V1::ApplicationController
        def create
          @gcm = Gcm.new(gcm_params)
          @gcm.user = current_user

          begin @gcm.save!
                render
          rescue ActiveRecord::RecordInvalid => e
            render_unprocessable_entity(e)
          end
        end

        private

        def gcm_params
          params.require(:gcm).permit(:registration_token)
        end
      end
    end
  end
end
