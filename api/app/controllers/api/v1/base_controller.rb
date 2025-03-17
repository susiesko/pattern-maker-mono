module Api
  module V1
    class BaseController < ApplicationController
      # Common functionality for all API v1 controllers
      
      # Return JSON response with error details
      def render_error(status, errors)
        render json: {
          success: false,
          errors: errors
        }, status: status
      end
    end
  end
end