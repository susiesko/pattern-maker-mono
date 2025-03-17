# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadBrandsController < Api::V1::BaseController
        before_action :set_brand, only: [:show, :update, :destroy]

        # GET /api/v1/catalog/bead_brands
        def index
          @brands = ::Catalog::BeadBrand.all.order(:name)
          
          render json: {
            success: true,
            data: @brands
          }
        end

        # GET /api/v1/catalog/bead_brands/:id
        def show
          render json: {
            success: true,
            data: @brand.as_json(
              include: [
                { bead_types: { only: [:id, :name] } }
              ]
            )
          }
        end

        # POST /api/v1/catalog/bead_brands
        def create
          @brand = ::Catalog::BeadBrand.new(brand_params)

          if @brand.save
            render json: {
              success: true,
              data: @brand,
              message: 'Bead brand created successfully'
            }, status: :created
          else
            render_error(:unprocessable_entity, @brand.errors.full_messages)
          end
        end

        # PATCH/PUT /api/v1/catalog/bead_brands/:id
        def update
          if @brand.update(brand_params)
            render json: {
              success: true,
              data: @brand,
              message: 'Bead brand updated successfully'
            }
          else
            render_error(:unprocessable_entity, @brand.errors.full_messages)
          end
        end

        # DELETE /api/v1/catalog/bead_brands/:id
        def destroy
          if @brand.destroy
            render json: {
              success: true,
              message: 'Bead brand deleted successfully'
            }
          else
            render_error(:unprocessable_entity, @brand.errors.full_messages)
          end
        end

        private

        def set_brand
          @brand = ::Catalog::BeadBrand.find_by(id: params[:id])
          render_error(:not_found, ['Bead brand not found']) unless @brand
        end

        def brand_params
          params.require(:bead_brand).permit(:name, :website)
        end
      end
    end
  end
end