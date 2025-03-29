# frozen_string_literal: true

module Api
  module V1
    class PasswordsController < ApplicationController
      before_action :authenticate_user!

      # PUT /api/v1/password
      def update
        user = current_user

        # Verify current password
        unless user.authenticate(password_params[:current_password])
          return render json: { error: 'Current password is incorrect' }, status: :unauthorized
        end

        if user.update(password: password_params[:password], password_confirmation: password_params[:password_confirmation])
          render json: { message: 'Password updated successfully' }, status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def password_params
        params.permit(:current_password, :password, :password_confirmation)
      end
    end
  end
end
