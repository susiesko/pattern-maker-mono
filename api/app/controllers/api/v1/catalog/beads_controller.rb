# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadsController < Api::V1::BaseController
        before_action :set_bead, only: [:show, :update, :destroy]

        # GET /api/v1/catalog/beads
        def index
          @beads = ::Catalog::Bead.includes(:brand, :size, :colors, :finishes)
                                  .order(created_at: :desc)
                                  
          # Apply filters if provided
          @beads = apply_filters(@beads)
          
          render json: {
            success: true,
            data: @beads.as_json(include: [:brand, :size, :colors, :finishes])
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
                { colors: { only: [:id, :name] } },
                { finishes: { only: [:id, :name] } }
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
              data: @bead.as_json(include: [:brand, :size, :colors, :finishes]),
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
              data: @bead.as_json(include: [:brand, :size, :colors, :finishes]),
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
          render_error(:not_found, ['Bead not found']) unless @bead
        end

        def bead_params
          params.require(:bead).permit(
            :name, 
            :brand_product_code, 
            :brand_id, 
            :size_id, 
            :image,
            metadata: {}
          )
        end
        
        def update_colors_and_finishes
          # Update colors if provided
          if params[:bead][:color_ids].present?
            @bead.color_ids = params[:bead][:color_ids]
          end
          
          # Update finishes if provided
          if params[:bead][:finish_ids].present?
            @bead.finish_ids = params[:bead][:finish_ids]
          end
        end
        
        def apply_filters(beads)
          filtered_beads = beads
          
          # Filter by brand
          if params[:brand_id].present?
            filtered_beads = filtered_beads.where(brand_id: params[:brand_id])
          end
          
          # Filter by size
          if params[:size_id].present?
            filtered_beads = filtered_beads.where(size_id: params[:size_id])
          end
          
          # Filter by color
          if params[:color_id].present?
            filtered_beads = filtered_beads.joins(:bead_color_links)
                                          .where(bead_color_links: { color_id: params[:color_id] })
                                          .distinct
          end
          
          # Filter by finish
          if params[:finish_id].present?
            filtered_beads = filtered_beads.joins(:bead_finish_links)
                                          .where(bead_finish_links: { finish_id: params[:finish_id] })
                                          .distinct
          end
          
          # Search by name or product code
          if params[:search].present?
            search_term = "%#{params[:search]}%"
            filtered_beads = filtered_beads.where(
              'name LIKE ? OR brand_product_code LIKE ?', 
              search_term, search_term
            )
          end
          
          filtered_beads
        end
      end
    end
  end
end