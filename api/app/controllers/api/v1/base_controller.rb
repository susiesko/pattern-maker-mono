# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      include Pagy::Backend

      skip_before_action :verify_authenticity_token, if: :json_request?

      protected

        def json_request?
          request.format.json?
        end

        def pagy_metadata(pagy)
          {
            current_page: pagy.page,
            next_page: pagy.next,
            prev_page: pagy.prev,
            total_pages: pagy.pages,
            total_count: pagy.count,
            per_page: pagy.items
          }
        end
    end
  end
end
