# frozen_string_literal: true
module A
  module V1
    class PublicationsController < ApplicationController
      before_action :require_authentication!,
                    only: [:subscribe, :unsubscribe]

      def index
        @publications = Feeder.order(priority: :asc)
                              .limit(30).offset(params[:offset])
      end

      def show
        @publication = Feeder.find(params[:id])
        user = current_user || NilUser.new
        @is_subscribing = user.subscribing?(@publication)
      end

      # TODO: Write controller test
      def featured
        unless current_user
          return @publications = Feeder.order(priority: :asc).limit(30)
        end

        subquery = current_user.feeders_users
        @publications = Feeder
                        .from("(#{subquery.to_sql}) AS fu "\
                          'RIGHT JOIN feeders ON fu.feeder_id = feeders.id')
                        .where('fu.user_id IS NULL')
                        .order(priority: :asc).limit(30)
      end

      def subscribe
        @publication = Feeder.find(params[:id])
        current_user.feeders << @publication
      end

      def unsubscribe
        @publication = Feeder.find(params[:id])
        current_user.feeders.destroy(@publication)
      end
    end
  end
end
