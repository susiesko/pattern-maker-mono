# frozen_string_literal: true

class AuthenticationService
  ALGORITHM = 'HS256'

  def self.encode(payload, exp = 24.hours.from_now)
    # Only set expiration if not already present in payload
    payload[:exp] ||= exp.to_i
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })[0]
    ActiveSupport::HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    raise ExceptionHandler::InvalidToken, e.message
  end

  def self.secret_key
    ENV.fetch('JWT_SECRET_KEY') { Rails.application.secret_key_base }
  end
end
