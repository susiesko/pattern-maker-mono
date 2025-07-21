# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  # Define custom error classes
  class AuthenticationError < StandardError; end
  class InvalidToken < StandardError; end
  class MissingToken < StandardError; end
  class UnauthorizedRequest < StandardError; end

  included do
    # Define custom handlers
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request
    rescue_from ExceptionHandler::MissingToken, with: :unprocessable_entity
    rescue_from ExceptionHandler::InvalidToken, with: :unauthorized_request
    rescue_from ExceptionHandler::UnauthorizedRequest, with: :unauthorized_request

    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end
  end

  private

  # Status code 422 - unprocessable entity
  def unprocessable_entity(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end

  # Status code 401 - Unauthorized
  def unauthorized_request(error)
    render json: { error: error.message }, status: :unauthorized
  end
end
