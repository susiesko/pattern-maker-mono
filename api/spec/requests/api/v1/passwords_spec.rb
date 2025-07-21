# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Passwords', type: :request do
  # Helper method to parse JSON response
  def json_response
    response.parsed_body
  end

  describe 'PUT /api/v1/password' do
    let(:user) { create(:user, password: 'current_password', password_confirmation: 'current_password') }
    let(:token) { AuthenticationService.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => token } }

    context 'when current password is correct and new password is valid' do
      let(:valid_params) do
        {
          current_password: 'current_password',
          password: 'new_password123',
          password_confirmation: 'new_password123',
        }
      end

      before do
        put '/api/v1/password', params: valid_params, headers: headers
      end

      it 'updates the password' do
        user.reload
        expect(user.authenticate('new_password123')).to be_truthy
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns success message' do
        expect(json_response['message']).to eq('Password updated successfully')
      end
    end

    context 'when current password is incorrect' do
      let(:invalid_params) do
        {
          current_password: 'wrong_password',
          password: 'new_password123',
          password_confirmation: 'new_password123',
        }
      end

      before do
        put '/api/v1/password', params: invalid_params, headers: headers
      end

      it 'does not update the password' do
        user.reload
        expect(user.authenticate('current_password')).to be_truthy
        expect(user.authenticate('new_password123')).to be_falsey
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns error message' do
        expect(json_response['error']).to eq('Current password is incorrect')
      end
    end

    context 'when new password is invalid' do
      let(:invalid_params) do
        {
          current_password: 'current_password',
          password: 'short',
          password_confirmation: 'short',
        }
      end

      before do
        put '/api/v1/password', params: invalid_params, headers: headers
      end

      it 'does not update the password' do
        user.reload
        expect(user.authenticate('current_password')).to be_truthy
        expect(user.authenticate('short')).to be_falsey
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns validation errors' do
        expect(json_response).to have_key('errors')
      end
    end

    context 'when password confirmation does not match' do
      let(:invalid_params) do
        {
          current_password: 'current_password',
          password: 'new_password123',
          password_confirmation: 'different_password',
        }
      end

      before do
        put '/api/v1/password', params: invalid_params, headers: headers
      end

      it 'does not update the password' do
        user.reload
        expect(user.authenticate('current_password')).to be_truthy
        expect(user.authenticate('new_password123')).to be_falsey
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns validation errors' do
        expect(json_response).to have_key('errors')
      end
    end
  end
end
