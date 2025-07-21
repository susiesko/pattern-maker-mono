# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadTypesController < Api::V1::BaseController
        # GET /api/v1/catalog/bead_types
        def index
          # Get distinct shapes from beads table
          @types = ::Catalog::Bead.distinct.pluck(:shape).compact.sort

          # Apply filters if provided
          @types = apply_filters(@types)

          render json: {
            success: true,
            data: @types.map { |type| { id: type, name: type } },
          }
        end

        # GET /api/v1/catalog/bead_types/:id
        def show
          type_name = params[:id]
          @type = { id: type_name, name: type_name }

          render json: {
            success: true,
            data: @type,
          }
        end

        private

        def apply_filters(types)
          filtered_types = types

          # Filter by brand if provided
          brand_param = params[:brand_id] || params[:brandId] || params[:brand]
          if brand_param.present?
            brand_types = ::Catalog::Bead.where(brand_id: brand_param)
                                         .distinct.pluck(:shape).compact
            filtered_types &= brand_types
          end

          # Search by type name
          search_param = params[:search]
          if search_param.present?
            filtered_types = filtered_types.select { |type| type.downcase.include?(search_param.downcase) }
          end

          filtered_types
        end
      end
    end
  end
end
