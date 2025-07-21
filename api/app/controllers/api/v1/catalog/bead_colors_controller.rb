# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadColorsController < Api::V1::BaseController
        # GET /api/v1/catalog/bead_colors
        def index
          # Get distinct color_groups from beads table
          @colors = ::Catalog::Bead.distinct.pluck(:color_group).compact.sort

          render json: {
            success: true,
            data: @colors,
          }
        end
      end
    end
  end
end
