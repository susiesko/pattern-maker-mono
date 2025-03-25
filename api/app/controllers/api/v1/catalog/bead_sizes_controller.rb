# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadSizesController < Api::V1::BaseController
        before_action :set_size, only: [ :show, :update, :destroy ]

        # GET /api/v1/catalog/bead_sizes
        def index
          @sizes = ::Catalog::BeadSize.includes(:brand, :type).all

          # Apply filters if provided
          @sizes = apply_filters(@sizes)

          render json: {
            success: true,
            data: @sizes.as_json(
              include: [
                { brand: { only: [ :id, :name ] } },
                { type: { only: [ :id, :name ] } }
              ]
            )
          }
        end

        # GET /api/v1/catalog/bead_sizes/:id
        def show
          render json: {
            success: true,
            data: @size.as_json(
              include: [
                { brand: { only: [ :id, :name ] } },
                { type: { only: [ :id, :name ] } }
              ]
            )
          }
        end

        # POST /api/v1/catalog/bead_sizes
        def create
          @size = ::Catalog::BeadSize.new(size_params)

          if @size.save
            render json: {
              success: true,
              data: @size.as_json(
                include: [
                  { brand: { only: [ :id, :name ] } },
                  { type: { only: [ :id, :name ] } }
                ]
              ),
              message: 'Bead size created successfully'
            }, status: :created
          else
            render_error(:unprocessable_entity, @size.errors.full_messages)
          end
        end

        # PATCH/PUT /api/v1/catalog/bead_sizes/:id
        def update
          if @size.update(size_params)
            render json: {
              success: true,
              data: @size.as_json(
                include: [
                  { brand: { only: [ :id, :name ] } },
                  { type: { only: [ :id, :name ] } }
                ]
              ),
              message: 'Bead size updated successfully'
            }
          else
            render_error(:unprocessable_entity, @size.errors.full_messages)
          end
        end

        # DELETE /api/v1/catalog/bead_sizes/:id
        def destroy
          if @size.destroy
            render json: {
              success: true,
              message: 'Bead size deleted successfully'
            }
          else
            render_error(:unprocessable_entity, @size.errors.full_messages)
          end
        end

        private

        def set_size
          @size = ::Catalog::BeadSize.find_by(id: params[:id])
          render_error(:not_found, [ 'Bead size not found' ]) unless @size
        end

        def size_params
          # Get the basic parameters
          permitted_params = params.require(:bead_size).permit(:size, :brand_id, :type_id)

          # Handle metadata separately to avoid JSON equality comparison issues
          if params[:bead_size][:metadata].present?
            # Convert to a regular Ruby hash to avoid PostgreSQL JSON equality comparison
            permitted_params[:metadata] = params[:bead_size][:metadata].permit!.to_h
          end

          permitted_params
        end

        def apply_filters(sizes)
          filtered_sizes = sizes

          # Filter by brand
          if params[:brand_id].present?
            filtered_sizes = filtered_sizes.where(brand_id: params[:brand_id])
          end

          # Filter by type
          if params[:type_id].present?
            filtered_sizes = filtered_sizes.where(type_id: params[:type_id])
          end

          filtered_sizes
        end
      end
    end
  end
end
