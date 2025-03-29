# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern

  included do
    # Make the current_user method available to views as well if needed
    helper_method :current_user if respond_to?(:helper_method)
  end

  def authenticate_user!
    raise ExceptionHandler::MissingToken, 'Missing token' unless token_present?

    current_user
  end

  def current_user
    @current_user ||= begin
      decoded_auth_token = AuthenticationService.decode(auth_token)
      User.find(decoded_auth_token[:user_id])
    end
  rescue ActiveRecord::RecordNotFound => e
    raise ExceptionHandler::InvalidToken, "Invalid token: #{e.message}"
  end

  private

  def token_present?
    auth_token.present?
  end

  def auth_token
    @auth_token ||= request.headers['Authorization']&.split(' ')&.last
  end
end
