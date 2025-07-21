# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadFinishesController < Api::V1::BaseController
        # GET /api/v1/catalog/bead_finishes
        def index
          # Get distinct finishes from beads table
          @finishes = ::Catalog::Bead.distinct.pluck(:finish).compact.sort

          # Apply filters if provided
          @finishes = apply_filters(@finishes)

          render json: {
            success: true,
            data: @finishes.map { |finish| { id: finish, name: finish } },
          }
        end

        # GET /api/v1/catalog/bead_finishes/:id
        def show
          finish_name = params[:id]
          @finish = { id: finish_name, name: finish_name }

          render json: {
            success: true,
            data: @finish,
          }
        end

        private

        def apply_filters(finishes)
          filtered_finishes = finishes

          # Filter by brand if provided
          brand_param = params[:brand_id] || params[:brandId] || params[:brand]
          if brand_param.present?
            brand_finishes = ::Catalog::Bead.where(brand_id: brand_param)
                                            .distinct.pluck(:finish).compact
            filtered_finishes &= brand_finishes
          end

          # Search by finish name
          search_param = params[:search]
          if search_param.present?
            filtered_finishes = filtered_finishes.select { |finish| finish.downcase.include?(search_param.downcase) }
          end

          filtered_finishes
        end
      end
    end
  end
end
