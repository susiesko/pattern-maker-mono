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
        # Log the parameters for debugging
        Rails.logger.info "Registration params: #{params.inspect}"
        Rails.logger.info "Registration params class: #{params.class}"
        Rails.logger.info "Registration params keys: #{params.keys}"
        Rails.logger.info "Registration params content type: #{request.content_type}"
        Rails.logger.info "Registration raw post: #{request.raw_post}"

        @user = User.new(user_params)
        Rails.logger.info "User attributes after initialization: #{@user.attributes.inspect}"

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
        # Log all parameters for debugging
        Rails.logger.info "User params method called with params: #{params.inspect}"

        # Create a new parameters hash with normalized keys
        normalized_params = ActionController::Parameters.new

        # Map frontend parameter names to our expected names
        if params[:name].present?
          normalized_params[:username] = params[:name]
        elsif params[:username].present?
          normalized_params[:username] = params[:username]
        end

        # Copy email parameter
        normalized_params[:email] = params[:email] if params[:email].present?

        # Copy password parameter
        normalized_params[:password] = params[:password] if params[:password].present?

        # Map confirmPassword to password_confirmation
        if params[:confirmPassword].present?
          normalized_params[:password_confirmation] = params[:confirmPassword]
        elsif params[:password_confirmation].present?
          normalized_params[:password_confirmation] = params[:password_confirmation]
        end

        # Copy first_name and last_name if present
        normalized_params[:first_name] = params[:first_name] if params[:first_name].present?
        normalized_params[:last_name] = params[:last_name] if params[:last_name].present?

        # Permit the parameters
        result = normalized_params.permit(:username, :email, :password, :password_confirmation, :first_name, :last_name)

        Rails.logger.info "Final user params: #{result.inspect}"
        result
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
