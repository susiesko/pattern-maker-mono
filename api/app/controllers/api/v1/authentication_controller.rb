# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApplicationController
      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: auth_params[:email])

        if user&.authenticate(auth_params[:password])
          user.update(last_login_at: Time.current)
          token = AuthenticationService.encode(user_id: user.id)
          render json: { token: token, user: user_response(user) }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # GET /api/v1/auth/me
      def me
        authenticate_user!
        render json: { user: user_response(current_user) }, status: :ok
      end

      private

      def auth_params
        params.permit(:email, :password)
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
