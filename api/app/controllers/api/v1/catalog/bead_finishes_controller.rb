# frozen_string_literal: true

module Api
  module V1
    module Catalog
      class BeadFinishesController < Api::V1::BaseController
        before_action :set_finish, only: [ :show, :update, :destroy ]

        # GET /api/v1/catalog/bead_finishes
        def index
          @finishes = ::Catalog::BeadFinish.all.order(:name)

          render json: {
            success: true,
            data: @finishes
          }
        end

        # GET /api/v1/catalog/bead_finishes/:id
        def show
          render json: {
            success: true,
            data: @finish
          }
        end

        # POST /api/v1/catalog/bead_finishes
        def create
          @finish = ::Catalog::BeadFinish.new(finish_params)

          if @finish.save
            render json: {
              success: true,
              data: @finish,
              message: 'Bead finish created successfully'
            }, status: :created
          else
            render_error(:unprocessable_entity, @finish.errors.full_messages)
          end
        end

        # PATCH/PUT /api/v1/catalog/bead_finishes/:id
        def update
          if @finish.update(finish_params)
            render json: {
              success: true,
              data: @finish,
              message: 'Bead finish updated successfully'
            }
          else
            render_error(:unprocessable_entity, @finish.errors.full_messages)
          end
        end

        # DELETE /api/v1/catalog/bead_finishes/:id
        def destroy
          if @finish.destroy
            render json: {
              success: true,
              message: 'Bead finish deleted successfully'
            }
          else
            render_error(:unprocessable_entity, @finish.errors.full_messages)
          end
        end

        private

        def set_finish
          @finish = ::Catalog::BeadFinish.find_by(id: params[:id])
          render_error(:not_found, [ 'Bead finish not found' ]) unless @finish
        end

        def finish_params
          params.require(:bead_finish).permit(:name)
        end
      end
    end
  end
end
