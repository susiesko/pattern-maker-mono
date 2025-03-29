# frozen_string_literal: true

class AuthenticationService
  ALGORITHM = 'HS256'

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key, true, { algorithm: ALGORITHM })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    raise ExceptionHandler::InvalidToken, e.message
  end

  def self.secret_key
    Rails.application.credentials.secret_key_base || Rails.application.secret_key_base
  end
end
