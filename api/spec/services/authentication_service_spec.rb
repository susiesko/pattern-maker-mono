# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationService do
  describe '.encode' do
    let(:user) { create(:user) }
    let(:payload) { { user_id: user.id } }

    it 'returns a JWT token' do
      token = described_class.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT tokens have 3 parts
    end

    it 'includes the payload in the token' do
      token = described_class.encode(payload)
      decoded_token = JWT.decode(token, described_class.secret_key, true, { algorithm: described_class::ALGORITHM })[0]
      expect(decoded_token['user_id']).to eq(user.id)
    end

    it 'sets an expiration time by default' do
      token = described_class.encode(payload)
      decoded_token = JWT.decode(token, described_class.secret_key, true, { algorithm: described_class::ALGORITHM })[0]
      expect(decoded_token).to have_key('exp')
    end

    it 'allows custom expiration time' do
      custom_exp = 1.hour.from_now
      token = described_class.encode(payload, custom_exp)
      decoded_token = JWT.decode(token, described_class.secret_key, true, { algorithm: described_class::ALGORITHM })[0]
      expect(decoded_token['exp']).to eq(custom_exp.to_i)
    end

    it 'respects expiration time in payload' do
      custom_exp = 2.hours.from_now.to_i
      payload_with_exp = payload.merge(exp: custom_exp)
      token = described_class.encode(payload_with_exp)
      decoded_token = JWT.decode(token, described_class.secret_key, true, { algorithm: described_class::ALGORITHM })[0]
      expect(decoded_token['exp']).to eq(custom_exp)
    end
  end

  describe '.decode' do
    let(:user) { create(:user) }
    let(:payload) { { user_id: user.id } }
    let(:token) { described_class.encode(payload) }

    it 'returns the decoded payload' do
      decoded_payload = described_class.decode(token)
      expect(decoded_payload[:user_id]).to eq(user.id)
    end

    it 'raises InvalidToken error when token is invalid' do
      expect {
        described_class.decode('invalid.token')
      }.to raise_error(ExceptionHandler::InvalidToken)
    end

    it 'raises InvalidToken error when token is expired' do
      expired_token = described_class.encode({ user_id: user.id }, 1.minute.ago)
      expect {
        described_class.decode(expired_token)
      }.to raise_error(ExceptionHandler::InvalidToken)
    end
  end

  describe '.secret_key' do
    it 'returns a non-nil secret key' do
      expect(described_class.secret_key).not_to be_nil
    end
  end
end