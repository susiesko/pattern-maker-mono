# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationService do
  describe '.encode' do
    let(:user) { create(:user) }
    let(:payload) { { user_id: user.id } }

    it 'returns a JWT token' do
      token = AuthenticationService.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT tokens have 3 parts
    end

    it 'includes the payload in the token' do
      token = AuthenticationService.encode(payload)
      decoded_token = JWT.decode(token, AuthenticationService.secret_key, true, { algorithm: described_class::ALGORITHM })[0]
      expect(decoded_token['user_id']).to eq(user.id)
    end

    it 'sets an expiration time by default' do
      token = AuthenticationService.encode(payload)
      decoded_token = JWT.decode(token, AuthenticationService.secret_key, true, { algorithm: described_class::ALGORITHM })[0]
      expect(decoded_token).to have_key('exp')
    end

    it 'allows custom expiration time' do
      custom_exp = 1.hour.from_now
      token = AuthenticationService.encode(payload, custom_exp)
      decoded_token = JWT.decode(token, AuthenticationService.secret_key, true, { algorithm: described_class::ALGORITHM })[0]
      expect(decoded_token['exp']).to eq(custom_exp.to_i)
    end

    it 'respects expiration time in payload' do
      custom_exp = 2.hours.from_now.to_i
      payload_with_exp = payload.merge(exp: custom_exp)
      token = AuthenticationService.encode(payload_with_exp)
      decoded_token = JWT.decode(token, AuthenticationService.secret_key, true, { algorithm: described_class::ALGORITHM })[0]
      expect(decoded_token['exp']).to eq(custom_exp)
    end
  end

  describe '.decode' do
    let(:user) { create(:user) }
    let(:payload) { { user_id: user.id } }
    let(:token) { AuthenticationService.encode(payload) }

    it 'returns the decoded payload' do
      decoded_payload = AuthenticationService.decode(token)
      expect(decoded_payload[:user_id]).to eq(user.id)
    end

    it 'raises InvalidToken error when token is invalid' do
      expect {
        AuthenticationService.decode('invalid.token')
      }.to raise_error(ExceptionHandler::InvalidToken)
    end

    it 'raises InvalidToken error when token is expired' do
      expired_token = AuthenticationService.encode({ user_id: user.id }, 1.minute.ago)
      expect {
        AuthenticationService.decode(expired_token)
      }.to raise_error(ExceptionHandler::InvalidToken)
    end
  end

  describe '.secret_key' do
    it 'returns a non-nil secret key' do
      expect(AuthenticationService.secret_key).not_to be_nil
    end
  end
end
