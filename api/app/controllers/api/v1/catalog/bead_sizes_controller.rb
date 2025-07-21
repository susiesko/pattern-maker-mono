# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadSizesController < Api::V1::BaseController
        # GET /api/v1/catalog/bead_sizes
        def index
          # Get distinct sizes from beads table
          @sizes = ::Catalog::Bead.distinct.pluck(:size).compact.sort

          # Apply filters if provided
          @sizes = apply_filters(@sizes)

          render json: {
            success: true,
            data: @sizes.map { |size| { id: size, name: size } },
          }
        end

        # GET /api/v1/catalog/bead_sizes/:id
        def show
          size_name = params[:id]
          @size = { id: size_name, name: size_name }

          render json: {
            success: true,
            data: @size,
          }
        end

        private

        def apply_filters(sizes)
          filtered_sizes = sizes

          # Filter by brand if provided
          brand_param = params[:brand_id] || params[:brandId] || params[:brand]
          if brand_param.present?
            brand_sizes = ::Catalog::Bead.where(brand_id: brand_param)
                                         .distinct.pluck(:size).compact
            filtered_sizes &= brand_sizes
          end

          # Search by size name
          search_param = params[:search]
          if search_param.present?
            filtered_sizes = filtered_sizes.select { |size| size.downcase.include?(search_param.downcase) }
          end

          filtered_sizes
        end
      end
    end
  end
end
