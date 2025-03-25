# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadsController < Api::V1::BaseController
        before_action :set_bead, only: [ :show, :update, :destroy ]

        # GET /api/v1/catalog/beads
        def index
          @beads = ::Catalog::Bead.includes(:brand, :size, :type, :colors, :finishes)
                                  .order(created_at: :desc)

          # Apply filters if provided
          @beads = apply_filters(@beads)

          render json: {
            success: true,
            data: @beads.as_json(include: [ :brand, :size, :type, :colors, :finishes ])
          }
        end

        # GET /api/v1/catalog/beads/:id
        def show
          render json: {
            success: true,
            data: @bead.as_json(
              include: [
                :brand,
                :size,
                { colors: { only: [ :id, :name ] } },
                { finishes: { only: [ :id, :name ] } }
              ]
            )
          }
        end

        # POST /api/v1/catalog/beads
        def create
          @bead = ::Catalog::Bead.new(bead_params)

          if @bead.save
            # Handle color and finish associations
            update_colors_and_finishes

            render json: {
              success: true,
              data: @bead.as_json(include: [ :brand, :size, :colors, :finishes ]),
              message: 'Bead created successfully'
            }, status: :created
          else
            render_error(:unprocessable_entity, @bead.errors.full_messages)
          end
        end

        # PATCH/PUT /api/v1/catalog/beads/:id
        def update
          if @bead.update(bead_params)
            # Handle color and finish associations
            update_colors_and_finishes

            render json: {
              success: true,
              data: @bead.as_json(include: [ :brand, :size, :colors, :finishes ]),
              message: 'Bead updated successfully'
            }
          else
            render_error(:unprocessable_entity, @bead.errors.full_messages)
          end
        end

        # DELETE /api/v1/catalog/beads/:id
        def destroy
          if @bead.destroy
            render json: {
              success: true,
              message: 'Bead deleted successfully'
            }
          else
            render_error(:unprocessable_entity, @bead.errors.full_messages)
          end
        end

        private

        def set_bead
          @bead = ::Catalog::Bead.find_by(id: params[:id])
          render_error(:not_found, [ 'Bead not found' ]) unless @bead
        end

        def bead_params
          # Get the parameters
          permitted_params = params.require(:bead).permit(
            :name,
            :brand_product_code,
            :brand_id,
            :size_id,
            :type_id,
            :image
          )

          # Handle metadata separately to avoid JSON equality comparison issues
          if params[:bead][:metadata].present?
            # Convert to a regular Ruby hash to avoid PostgreSQL JSON equality comparison
            permitted_params[:metadata] = params[:bead][:metadata].permit!.to_h
          end

          permitted_params
        end

        def update_colors_and_finishes
          bead_params = params[:bead]

          # Handle both camelCase and snake_case parameter names
          color_ids = bead_params[:color_ids].present? ? bead_params[:color_ids] : bead_params[:colorIds]
          finish_ids = bead_params[:finish_ids].present? ? bead_params[:finish_ids] : bead_params[:finishIds]

          # Update colors if provided
          if color_ids.present?
            @bead.color_ids = color_ids
          end

          # Update finishes if provided
          if finish_ids.present?
            @bead.finish_ids = finish_ids
          end
        end

        def apply_filters(beads)
          filtered_beads = beads

          # Helper method to get parameter value from either snake_case or camelCase
          def get_param(snake_case_key, camel_case_key = nil)
            camel_case_key ||= snake_case_key.camelize(:lower)
            params[snake_case_key].present? ? params[snake_case_key] : params[camel_case_key]
          end

          # Filter by brand
          brand_param = params[:brand_id] || params[:brandId] || params[:brand]
          if brand_param.present?
            filtered_beads = filtered_beads.where(brand_id: brand_param)
          end

          # Filter by size
          size_param = params[:size_id] || params[:sizeId] || params[:size]
          if size_param.present?
            filtered_beads = filtered_beads.where(size_id: size_param)
          end

          # Filter by type
          type_param = params[:type_id] || params[:typeId] || params[:type]
          if type_param.present?
            filtered_beads = filtered_beads.where(type_id: type_param)
          end

          # Filter by color
          color_param = params[:color_id] || params[:colorId] || params[:color]
          if color_param.present?
            # Use a subquery approach to avoid DISTINCT with JSON columns
            bead_ids = ::Catalog::BeadColorLink.where(color_id: color_param).pluck(:bead_id).uniq
            filtered_beads = filtered_beads.where(id: bead_ids)
          end

          # Filter by finish
          finish_param = params[:finish_id] || params[:finishId] || params[:finish]
          if finish_param.present?
            # Use a subquery approach to avoid DISTINCT with JSON columns
            bead_ids = ::Catalog::BeadFinishLink.where(finish_id: finish_param).pluck(:bead_id).uniq
            filtered_beads = filtered_beads.where(id: bead_ids)
          end

          # Search by name or product code
          search_param = params[:search]
          if search_param.present?
            search_pattern = "%#{search_param}%"
            filtered_beads = filtered_beads.where(
              'name ILIKE ? OR brand_product_code ILIKE ?',
              search_pattern, search_pattern
            )
          end

          filtered_beads
        end
      end
    end
  end
end
