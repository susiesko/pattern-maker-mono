# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!, except: [ :create ]
      before_action :set_user, only: [ :show, :update, :destroy ]
      before_action :authorize_user!, only: [ :update, :destroy ]

      # GET /api/v1/users
      def index
        authorize_admin!
        @users = User.all
        render json: @users, status: :ok
      end

      # GET /api/v1/users/:id
      def show
        render json: @user, status: :ok
      end

      # POST /api/v1/users
      def create
        @user = User.new(user_params)

        if @user.save
          token = AuthenticationService.encode(user_id: @user.id)
          render json: {
            message: 'User created successfully',
            token: token,
            user: user_response(@user)
          }, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/users/:id
      def update
        if @user.update(user_update_params)
          render json: { message: 'User updated successfully', user: user_response(@user) }, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        render json: { message: 'User deleted successfully' }, status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.permit(:username, :email, :password, :password_confirmation, :first_name, :last_name)
      end

      def user_update_params
        # Don't allow password update through this endpoint for security
        params.permit(:username, :email, :first_name, :last_name)
      end

      def authorize_user!
        unless current_user.id == @user.id || current_user.admin?
          raise ExceptionHandler::UnauthorizedRequest, 'You are not authorized to perform this action'
        end
      end

      def authorize_admin!
        unless current_user.admin?
          raise ExceptionHandler::UnauthorizedRequest, 'Admin access required'
        end
      end

      def user_response(user)
        {
          id: user.id,
          username: user.username,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          admin: user.admin,
          created_at: user.created_at
        }
      end
    end
  end
end
