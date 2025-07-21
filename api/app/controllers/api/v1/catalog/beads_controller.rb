# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadsController < Api::V1::BaseController
        before_action :set_bead, only: %i[show update destroy]

        # GET /api/v1/catalog/beads
        def index # rubocop:disable Metrics/MethodLength
          @beads = ::Catalog::Bead.includes(:brand)

          # Apply filters if provided
          @beads = apply_filters(@beads)

          # Apply sorting
          sort_config = parse_sort_config
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
            data: pagination_result[:records].as_json(include: %i[brand]),
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
              ],
            ),
          }
        end

        # POST /api/v1/catalog/beads
        def create
          @bead = ::Catalog::Bead.new(bead_params)

          if @bead.save
            render json: {
              success: true,
              data: @bead.as_json(include: %i[brand]),
              message: 'Bead created successfully',
            }, status: :created
          else
            render_error(:unprocessable_entity, @bead.errors.full_messages)
          end
        end

        # PATCH/PUT /api/v1/catalog/beads/:id
        def update
          if @bead.update(bead_params)
            render json: {
              success: true,
              data: @bead.as_json(include: %i[brand]),
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
          @bead = ::Catalog::Bead.includes(:brand)
                                 .find_by(id: params[:id])
          render_error(:not_found, ['Bead not found']) unless @bead
        end

        # Helper method to get parameter value from either snake_case or camelCase
        def get_param(snake_case_key, camel_case_key = nil)
          camel_case_key ||= snake_case_key.camelize(:lower)
          params[snake_case_key].presence || params[camel_case_key]
        end

        def bead_params # rubocop:disable Metrics/MethodLength
          # Get the parameters
          permitted_params = params.expect(
            bead: [:name,
                   :brand_product_code,
                   :brand_id,
                   :image,
                   # New detailed attributes
                   :shape,
                   :size,
                   :color_group,
                   :glass_group,
                   :finish,
                   :dyed,
                   :galvanized,
                   :plating],
          )

          # Handle metadata separately to avoid JSON equality comparison issues
          if params[:bead][:metadata].present?
            # Convert to a regular Ruby hash to avoid PostgreSQL JSON equality comparison
            permitted_params[:metadata] = params[:bead][:metadata].permit!.to_h
          end

          permitted_params
        end

        def apply_filters(beads) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
          filtered_beads = beads

          # Filter by brand
          brand_param = params[:brand_id] || params[:brandId] || params[:brand]
          filtered_beads = filtered_beads.where(brand_id: brand_param) if brand_param.present?

          # Search by name or product code
          search_param = params[:search]
          if search_param.present?
            search_pattern = "%#{search_param}%"
            filtered_beads = filtered_beads.where(
              'name ILIKE ? OR brand_product_code ILIKE ?',
              search_pattern, search_pattern
            )
          end

          # Filter by new detailed attributes
          shape_param = params[:shape]
          filtered_beads = filtered_beads.by_shape(shape_param) if shape_param.present?

          size_param = params[:size]
          filtered_beads = filtered_beads.by_size(size_param) if size_param.present?

          color_group_param = params[:color_group]
          filtered_beads = filtered_beads.by_color_group(color_group_param) if color_group_param.present?

          glass_group_param = params[:glass_group]
          filtered_beads = filtered_beads.by_glass_group(glass_group_param) if glass_group_param.present?

          finish_param = params[:finish]
          filtered_beads = filtered_beads.by_finish(finish_param) if finish_param.present?

          dyed_param = params[:dyed]
          filtered_beads = filtered_beads.by_dyed(dyed_param) if dyed_param.present?

          galvanized_param = params[:galvanized]
          filtered_beads = filtered_beads.by_galvanized(galvanized_param) if galvanized_param.present?

          plating_param = params[:plating]
          filtered_beads = filtered_beads.by_plating(plating_param) if plating_param.present?

          filtered_beads
        end

        def parse_sort_config
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
