module A
  module V1
    module Me
      class GcmController < A::V1::ApplicationController
        def create
          @gcm = fetch_gcm
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

        def fetch_gcm
          begin
            gcm = Gcm.find(params[:gcm][:registration_token])
          rescue ActiveRecord::RecordNotFound
            gcm = Gcm.new(gcm_params)
          end

          gcm
        end
      end
    end
  end
end
