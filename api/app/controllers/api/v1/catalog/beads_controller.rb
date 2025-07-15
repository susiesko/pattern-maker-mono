# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadsController < Api::V1::BaseController
        before_action :set_bead, only: %i[show update destroy]

        # GET /api/v1/catalog/beads
        def index
          @beads = ::Catalog::Bead.includes(:brand, :size, :type, :colors, :finishes)

          # Apply filters if provided
          @beads = apply_filters(@beads)

          # Apply sorting
          sort_config = get_sort_config
          @beads = @beads.order(sort_config[:field] => sort_config[:direction])

          # Apply pagination
          page = params[:page] || 1
          per_page = params[:per_page] || params[:limit] || 20

          pagination_result = PaginationService.new(
            @beads,
            page: page,
            per_page: per_page,
          ).paginate

          render json: {
            success: true,
            data: pagination_result[:records].as_json(include: %i[brand size type colors finishes]),
            pagination: pagination_result[:pagination],
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
                :type,
                { colors: { only: [:id, :name] } },
                { finishes: { only: [:id, :name] } },
              ],
            ),
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
              data: @bead.as_json(include: %i[brand size type colors finishes]),
              message: 'Bead created successfully',
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
              data: @bead.as_json(include: %i[brand size type colors finishes]),
              message: 'Bead updated successfully',
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
              message: 'Bead deleted successfully',
            }
          else
            render_error(:unprocessable_entity, @bead.errors.full_messages)
          end
        end

        private

        def set_bead
          @bead = ::Catalog::Bead.includes(:brand, :size, :type, :colors, :finishes)
                                 .find_by(id: params[:id])
          render_error(:not_found, ['Bead not found']) unless @bead
        end

        def bead_params
          # Get the parameters
          permitted_params = params.require(:bead).permit(
            :name,
            :brand_product_code,
            :brand_id,
            :size_id,
            :type_id,
            :image,
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
          color_ids = bead_params[:color_ids].presence || bead_params[:colorIds]
          finish_ids = bead_params[:finish_ids].presence || bead_params[:finishIds]

          # Update colors if provided
          @bead.color_ids = color_ids if color_ids.present?

          # Update finishes if provided
          return unless finish_ids.present?

          @bead.finish_ids = finish_ids
        end

        def apply_filters(beads)
          filtered_beads = beads

          # Helper method to get parameter value from either snake_case or camelCase
          def get_param(snake_case_key, camel_case_key = nil)
            camel_case_key ||= snake_case_key.camelize(:lower)
            params[snake_case_key].presence || params[camel_case_key]
          end

          # Filter by brand
          brand_param = params[:brand_id] || params[:brandId] || params[:brand]
          filtered_beads = filtered_beads.where(brand_id: brand_param) if brand_param.present?

          # Filter by size
          size_param = params[:size_id] || params[:sizeId] || params[:size]
          filtered_beads = filtered_beads.where(size_id: size_param) if size_param.present?

          # Filter by type
          type_param = params[:type_id] || params[:typeId] || params[:type]
          filtered_beads = filtered_beads.where(type_id: type_param) if type_param.present?

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

        def get_sort_config
          sort_by = params[:sort_by] || 'id'
          direction = params[:direction] || 'desc'

          # Validate direction
          direction = 'desc' unless %w[asc desc].include?(direction)

          # Map sort options to database fields
          case sort_by
          when 'product_code', 'brand_product_code'
            { field: :brand_product_code, direction: direction.to_sym }
          when 'name'
            { field: :name, direction: direction.to_sym }
          when 'created_at', 'date'
            { field: :created_at, direction: direction.to_sym }
          else
            # Default to id
            { field: :id, direction: direction.to_sym }
          end
        end
      end
    end
  end
end
