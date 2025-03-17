# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadColorsController < Api::V1::BaseController
        before_action :set_color, only: [:show, :update, :destroy]

        # GET /api/v1/catalog/bead_colors
        def index
          @colors = ::Catalog::BeadColor.all.order(:name)
          
          render json: {
            success: true,
            data: @colors
          }
        end

        # GET /api/v1/catalog/bead_colors/:id
        def show
          render json: {
            success: true,
            data: @color
          }
        end

        # POST /api/v1/catalog/bead_colors
        def create
          @color = ::Catalog::BeadColor.new(color_params)

          if @color.save
            render json: {
              success: true,
              data: @color,
              message: 'Bead color created successfully'
            }, status: :created
          else
            render_error(:unprocessable_entity, @color.errors.full_messages)
          end
        end

        # PATCH/PUT /api/v1/catalog/bead_colors/:id
        def update
          if @color.update(color_params)
            render json: {
              success: true,
              data: @color,
              message: 'Bead color updated successfully'
            }
          else
            render_error(:unprocessable_entity, @color.errors.full_messages)
          end
        end

        # DELETE /api/v1/catalog/bead_colors/:id
        def destroy
          if @color.destroy
            render json: {
              success: true,
              message: 'Bead color deleted successfully'
            }
          else
            render_error(:unprocessable_entity, @color.errors.full_messages)
          end
        end

        private

        def set_color
          @color = ::Catalog::BeadColor.find_by(id: params[:id])
          render_error(:not_found, ['Bead color not found']) unless @color
        end

        def color_params
          params.require(:bead_color).permit(:name)
        end
      end
    end
  end
end