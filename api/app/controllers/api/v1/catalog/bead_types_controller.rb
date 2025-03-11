module Api
  module V1
    module Catalog
      class BeadTypesController < BaseController
        def index
          @pagy, @bead_types = ::Catalog::FetchBeadTypesService.new(filter_params, self).call

          render json: {
            bead_types: ActiveModelSerializers::SerializableResource.new(@bead_types,
                                                                         each_serializer: BeadTypeSerializer),
            meta: pagy_metadata(@pagy)
          }
        end

        def show
          @bead_type = ::Catalog::FetchBeadTypeService.new(params[:id]).call
          render json: @bead_type, serializer: BeadTypeSerializer
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Bead type not found' }, status: :not_found
        end

        private

          def filter_params
            params.permit(:brand_id, :search, :sort_by, :sort_direction, :items, :page)
          end
      end
    end
  end
end
