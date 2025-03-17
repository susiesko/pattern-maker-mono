# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include ApiResponse
      include ErrorHandler

      skip_before_action :verify_authenticity_token, if: :json_request?
      after_action :ensure_success_status

      protected

        def json_request?
          request.format.json?
        end

        def ensure_success_status
          # Force success status for all API responses
          response.status = 200 unless response.redirect?
        end
    end
  end
end
