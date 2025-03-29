# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  # Helper method to parse JSON response
  def json_response
    JSON.parse(response.body)
  end

  describe 'POST /api/v1/users' do
    let(:valid_attributes) do
      {
        username: 'newuser',
        email: 'newuser@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'New',
        last_name: 'User'
      }
    end

    context 'when the request is valid' do
      before do
        post '/api/v1/users', params: valid_attributes
      end

      it 'creates a new user' do
        expect(User.find_by(email: 'newuser@example.com')).not_to be_nil
      end

      it 'returns a token' do
        expect(json_response).to have_key('token')
        expect(json_response['token']).not_to be_nil
      end

      it 'returns the user information' do
        expect(json_response['user']).to include(
          'username' => 'newuser',
          'email' => 'newuser@example.com',
          'first_name' => 'New',
          'last_name' => 'User'
        )
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before do
        post '/api/v1/users', params: { username: 'u', email: 'invalid', password: 'short' }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns validation errors' do
        expect(json_response).to have_key('errors')
        expect(json_response['errors']).to be_an(Array)
        expect(json_response['errors']).not_to be_empty
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationService.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => token } }

    context 'when the user exists' do
      before do
        get "/api/v1/users/#{user.id}", headers: headers
      end

      it 'returns the user' do
        expect(json_response).to include(
          'id' => user.id,
          'username' => user.username,
          'email' => user.email
        )
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the user does not exist' do
      before do
        get '/api/v1/users/999', headers: headers
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json_response['error']).to match(/Couldn't find User/)
      end
    end
  end

  describe 'PUT /api/v1/users/:id' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationService.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => token } }
    let(:valid_attributes) { { first_name: 'Updated', last_name: 'Name' } }

    context 'when the user updates their own profile' do
      before do
        put "/api/v1/users/#{user.id}", params: valid_attributes, headers: headers
      end

      it 'updates the user' do
        user.reload
        expect(user.first_name).to eq('Updated')
        expect(user.last_name).to eq('Name')
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns success message' do
        expect(json_response['message']).to eq('User updated successfully')
      end
    end

    context 'when a user tries to update another user' do
      let(:another_user) { create(:user) }
      let(:another_token) { AuthenticationService.encode(user_id: another_user.id) }
      let(:another_headers) { { 'Authorization' => another_token } }

      before do
        put "/api/v1/users/#{user.id}", params: valid_attributes, headers: another_headers
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns an unauthorized message' do
        expect(json_response['error']).to match(/not authorized/)
      end
    end
  end

  describe 'DELETE /api/v1/users/:id' do
    let(:user) { create(:user) }
    let(:token) { AuthenticationService.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => token } }

    context 'when a user deletes their own account' do
      before do
        delete "/api/v1/users/#{user.id}", headers: headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'deletes the user' do
        expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a user tries to delete another user' do
      let(:another_user) { create(:user) }
      let(:another_token) { AuthenticationService.encode(user_id: another_user.id) }
      let(:another_headers) { { 'Authorization' => another_token } }

      before do
        delete "/api/v1/users/#{user.id}", headers: another_headers
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'does not delete the user' do
        expect(User.find(user.id)).to eq(user)
      end
    end

    context 'when an admin deletes another user' do
      let(:admin) { create(:user, :admin) }
      let(:admin_token) { AuthenticationService.encode(user_id: admin.id) }
      let(:admin_headers) { { 'Authorization' => admin_token } }

      before do
        delete "/api/v1/users/#{user.id}", headers: admin_headers
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'deletes the user' do
        expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
