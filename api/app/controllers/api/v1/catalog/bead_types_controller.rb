# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadTypesController < BaseController
        def index
          @bead_types = ::Catalog::FetchBeadTypesService.new(filter_params).call

          # Manually serialize each bead type to avoid namespace issues
          serialized_bead_types = @bead_types.map do |bead_type|
            ::Catalog::BeadTypeSerializer.new(bead_type).as_json
          end

          render json: { bead_types: serialized_bead_types }
        end

        def show
          @bead_type = ::Catalog::FetchBeadTypeService.new(params[:id]).call
          render json: ::Catalog::BeadTypeSerializer.new(@bead_type).as_json
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Bead type not found' }, status: :not_found
        end

        private

          def filter_params
            params.permit(:brand_id, :search, :sort_by, :sort_direction)
          end
      end
    end
  end
end
