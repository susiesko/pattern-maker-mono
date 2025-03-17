# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadTypesController < BaseController
        include ::Catalog

        def index
          @bead_types = FetchBeadTypesService.call(filter_params)

          render json: {
            bead_types: ActiveModelSerializers::SerializableResource.new(
              @bead_types,
              each_serializer: BeadTypeSerializer
            )
          }
        end

        def show
          @bead_type = FetchBeadTypeService.call(params[:id])
          render json: @bead_type, serializer: BeadTypeSerializer
        end

        private

          def filter_params
            params.permit(:brand_id, :search, :sort_by, :sort_direction)
          end
      end
    end
  end
end
