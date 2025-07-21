# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadTypesController < Api::V1::BaseController
        # GET /api/v1/catalog/bead_types
        def index
          # Get distinct shapes from beads table
          @shapes = ::Catalog::Bead.distinct.pluck(:shape).compact.sort

          render json: {
            success: true,
            data: @shapes,
          }
        end
      end
    end
  end
end
