# frozen_string_literal: true

module Api
  module V1
    class StatusController < BaseController
      def index
        render json: {
          success: true,
          api_version: 'v1',
          status: 'online',
          timestamp: Time.current,
        }
      end
    end
  end
end
