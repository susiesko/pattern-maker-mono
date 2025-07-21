# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadSizesController < Api::V1::BaseController
        # GET /api/v1/catalog/bead_sizes
        def index
          # Get distinct sizes from beads table
          @sizes = ::Catalog::Bead.distinct.pluck(:size).compact.sort

          render json: {
            success: true,
            data: @sizes,
          }
        end
      end
    end
  end
end
