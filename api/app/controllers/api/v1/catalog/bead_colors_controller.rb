# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadColorsController < Api::V1::BaseController
        # GET /api/v1/catalog/bead_colors
        def index
          # Get distinct color_groups from beads table
          @colors = ::Catalog::Bead.distinct.pluck(:color_group).compact.sort

          # Apply filters if provided
          @colors = apply_filters(@colors)

          render json: {
            success: true,
            data: @colors.map { |color| { id: color, name: color } },
          }
        end

        # GET /api/v1/catalog/bead_colors/:id
        def show
          color_name = params[:id]
          @color = { id: color_name, name: color_name }

          render json: {
            success: true,
            data: @color,
          }
        end

        private

        def apply_filters(colors)
          filtered_colors = colors

          # Filter by brand if provided
          brand_param = params[:brand_id] || params[:brandId] || params[:brand]
          if brand_param.present?
            brand_colors = ::Catalog::Bead.where(brand_id: brand_param)
                                          .distinct.pluck(:color_group).compact
            filtered_colors &= brand_colors
          end

          # Search by color name
          search_param = params[:search]
          if search_param.present?
            filtered_colors = filtered_colors.select { |color| color.downcase.include?(search_param.downcase) }
          end

          filtered_colors
        end
      end
    end
  end
end
