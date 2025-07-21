# frozen_string_literal: true

module Api
  module V1
    class InventoriesController < BaseController
      before_action :authenticate_user!
      before_action :set_inventory, only: %i[show update destroy]

      # GET /api/v1/inventories
      def index
        @inventories = current_user.inventories.includes(bead: :brand)
        render json: @inventories, include: { bead: { include: :brand } }
      end

      # GET /api/v1/inventories/:id
      def show
        render json: @inventory, include: { bead: { include: :brand } }
      end

      # POST /api/v1/inventories
      def create
        @inventory = current_user.inventories.build(inventory_params)

        if @inventory.save
          render json: @inventory, include: { bead: { include: :brand } }, status: :created
        else
          render json: { error: @inventory.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/inventories/:id
      def update
        if @inventory.update(inventory_params)
          render json: @inventory, include: { bead: { include: :brand } }
        else
          render json: { error: @inventory.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/inventories/:id
      def destroy
        @inventory.destroy
        head :no_content
      end

      private

      def set_inventory
        @inventory = current_user.inventories.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Inventory item not found' }, status: :not_found
      end

      def inventory_params
        params.expect(inventory: %i[bead_id quantity quantity_unit])
      end
    end
  end
end
