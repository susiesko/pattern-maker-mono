# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?

      protected

        def json_request?
          request.format.json?
        end
    end
  end
end
