# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadFinishesController < Api::V1::BaseController
        # GET /api/v1/catalog/bead_finishes
        def index
          # Get distinct finishes from beads table
          @finishes = ::Catalog::Bead.distinct.pluck(:finish).compact.sort

          render json: {
            success: true,
            data: @finishes,
          }
        end
      end
    end
  end
end
