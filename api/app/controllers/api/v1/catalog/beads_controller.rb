# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadsController < BaseController
        include ::Catalog
        def index
          @beads = FetchBeadsService.call(filter_params)

          render json: {
            beads: ActiveModelSerializers::SerializableResource.new(@beads, each_serializer: BeadSerializer)
          }
        end

        def show
          bead = FetchBeadService.call(params[:id])
          render json: bead, serializer: BeadSerializer
        end

        private

          def filter_params
            params.permit(:brand_id, :type_id, :size_id, :color_id, :finish_id, :search, :sort_by, :sort_direction)
          end
      end
    end
  end
end
