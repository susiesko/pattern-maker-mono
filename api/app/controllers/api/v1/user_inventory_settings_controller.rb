# frozen_string_literal: true

module Api
  module V1
    class UserInventorySettingsController < BaseController
      before_action :authenticate_user!
      before_action :set_user_inventory_setting, only: [:show, :update]

      # GET /api/v1/inventory-settings
      def show
        render json: @setting
      end

      # POST /api/v1/inventory-settings
      def create
        if current_user.user_inventory_setting.present?
          render json: { error: 'User already has inventory settings' }, status: :unprocessable_entity
          return
        end

        @setting = current_user.build_user_inventory_setting(setting_params)

        if @setting.save
          render json: @setting, status: :created
        else
          render json: { error: @setting.errors }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/inventory-settings
      def update
        if @setting.update(setting_params)
          render json: @setting
        else
          render json: { error: @setting.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_user_inventory_setting
        @setting = current_user.user_inventory_setting
        return if @setting

        render json: { error: 'Inventory settings not found' }, status: :not_found
      end

      def setting_params
        # Allow the entire field_definitions array without restrictive permissions
        # since it's validated by the model
        params.require(:user_inventory_setting).permit!
      end
    end
  end
end
