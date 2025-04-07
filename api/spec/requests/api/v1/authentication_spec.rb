# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Authentication', type: :request do
  describe 'POST /api/v1/auth/login' do
    let!(:user) { create(:user, email: 'user@example.com', password: 'password123', password_confirmation: 'password123') }

    context 'when credentials are valid' do
      before do
        post '/api/v1/auth/login', params: { email: 'user@example.com', password: 'password123' }
      end

      it 'returns a token' do
        expect(json_response).to have_key('token')
        expect(json_response['token']).not_to be_nil
      end

      it 'returns user information' do
        expect(json_response['user']).to include(
          'id' => user.id,
          'username' => user.username,
          'email' => user.email
        )
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'updates last_login_at' do
        user.reload
        expect(user.last_login_at).not_to be_nil
      end
    end

    context 'when credentials are valid with nested parameters' do
      before do
        post '/api/v1/auth/login', params: { authentication: { email: 'user@example.com', password: 'password123' } }
      end

      it 'returns a token' do
        expect(json_response).to have_key('token')
        expect(json_response['token']).not_to be_nil
      end

      it 'returns user information' do
        expect(json_response['user']).to include(
          'id' => user.id,
          'username' => user.username,
          'email' => user.email
        )
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when email is provided with different case' do
      before do
        post '/api/v1/auth/login', params: { email: 'USER@example.com', password: 'password123' }
      end

      it 'returns a token' do
        expect(json_response).to have_key('token')
        expect(json_response['token']).not_to be_nil
      end

      it 'returns user information' do
        expect(json_response['user']).to include(
          'id' => user.id,
          'username' => user.username,
          'email' => user.email
        )
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when credentials are invalid' do
      before do
        post '/api/v1/auth/login', params: { email: 'user@example.com', password: 'wrong_password' }
      end

      it 'returns an error message' do
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when email does not exist' do
      before do
        post '/api/v1/auth/login', params: { email: 'nonexistent@example.com', password: 'password123' }
      end

      it 'returns an error message' do
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when parameters are missing' do
      before do
        post '/api/v1/auth/login', params: {}
      end

      it 'returns an error message' do
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when only email is provided' do
      before do
        post '/api/v1/auth/login', params: { email: 'user@example.com' }
      end

      it 'returns an error message' do
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when only password is provided' do
      before do
        post '/api/v1/auth/login', params: { password: 'password123' }
      end

      it 'returns an error message' do
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'GET /api/v1/auth/me' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationService.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    context 'when token is valid' do
      before do
        get '/api/v1/auth/me', headers: headers
      end

      it 'returns the user information' do
        expect(json_response['user']).to include(
          'id' => user.id,
          'username' => user.username,
          'email' => user.email
        )
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when token is invalid' do
      before do
        get '/api/v1/auth/me', headers: { 'Authorization' => 'Bearer invalid_token' }
      end

      it 'returns an error message' do
        expect(json_response).to have_key('error')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when token is expired' do
      # Create a token that's already expired
      let(:expired_token) do
        payload = { user_id: user.id, exp: 1.minute.ago.to_i }
        JWT.encode(payload, AuthenticationService.secret_key, AuthenticationService::ALGORITHM)
      end
      let(:expired_headers) { { 'Authorization' => "Bearer #{expired_token}" } }

      before do
        get '/api/v1/auth/me', headers: expired_headers
      end

      it 'returns an error message' do
        expect(json_response).to have_key('error')
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when token is missing' do
      before do
        get '/api/v1/auth/me'
      end

      it 'returns an error message' do
        expect(json_response['error']).to eq('Missing token')
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  # Helper method to parse JSON response
  def json_response
    JSON.parse(response.body)
  end
end
