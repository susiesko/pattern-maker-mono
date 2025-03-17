# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadTypesController < Api::V1::BaseController
        before_action :set_type, only: [:show, :update, :destroy]

        # GET /api/v1/catalog/bead_types
        def index
          @types = ::Catalog::BeadType.includes(:brand).all
          
          # Filter by brand if provided
          @types = @types.where(brand_id: params[:brand_id]) if params[:brand_id].present?
          
          render json: {
            success: true,
            data: @types.as_json(include: { brand: { only: [:id, :name] } })
          }
        end

        # GET /api/v1/catalog/bead_types/:id
        def show
          render json: {
            success: true,
            data: @type.as_json(
              include: [
                { brand: { only: [:id, :name] } },
                { bead_sizes: { only: [:id, :size] } }
              ]
            )
          }
        end

        # POST /api/v1/catalog/bead_types
        def create
          @type = ::Catalog::BeadType.new(type_params)

          if @type.save
            render json: {
              success: true,
              data: @type.as_json(include: { brand: { only: [:id, :name] } }),
              message: 'Bead type created successfully'
            }, status: :created
          else
            render_error(:unprocessable_entity, @type.errors.full_messages)
          end
        end

        # PATCH/PUT /api/v1/catalog/bead_types/:id
        def update
          if @type.update(type_params)
            render json: {
              success: true,
              data: @type.as_json(include: { brand: { only: [:id, :name] } }),
              message: 'Bead type updated successfully'
            }
          else
            render_error(:unprocessable_entity, @type.errors.full_messages)
          end
        end

        # DELETE /api/v1/catalog/bead_types/:id
        def destroy
          if @type.destroy
            render json: {
              success: true,
              message: 'Bead type deleted successfully'
            }
          else
            render_error(:unprocessable_entity, @type.errors.full_messages)
          end
        end

        private

        def set_type
          @type = ::Catalog::BeadType.find_by(id: params[:id])
          render_error(:not_found, ['Bead type not found']) unless @type
        end

        def type_params
          params.require(:bead_type).permit(:name, :brand_id)
        end
      end
    end
  end
end