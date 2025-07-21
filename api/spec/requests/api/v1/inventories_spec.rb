# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Inventories', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:bead) { create(:bead) }
  let(:other_bead) { create(:bead) }
  let(:token) { AuthenticationService.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/inventories' do
    let!(:first_user_inventory) { create(:inventory, user: user, bead: bead, quantity: 10.5) }
    let!(:second_user_inventory) { create(:inventory, user: user, bead: other_bead, quantity: 25.0) }
    let!(:other_user_inventory) { create(:inventory, user: other_user, bead: bead, quantity: 5.0) }

    it 'returns only current user inventories' do
      get '/api/v1/inventories', headers: headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response.length).to eq(2)
      inventory_ids = json_response.map { |inv| inv['id'] }
      expect(inventory_ids).to include(first_user_inventory.id, second_user_inventory.id)
      expect(inventory_ids).not_to include(other_user_inventory.id)
    end

    it 'includes bead and brand information' do
      get '/api/v1/inventories', headers: headers

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body

      first_inventory = json_response.first
      expect(first_inventory).to have_key('bead')
      expect(first_inventory['bead']).to have_key('brand')
    end
  end

  describe 'GET /api/v1/inventories/:id' do
    let!(:inventory) { create(:inventory, user: user, bead: bead) }
    let!(:other_user_inventory) { create(:inventory, user: other_user, bead: bead) }

    it 'returns the specific inventory item' do
      get "/api/v1/inventories/#{inventory.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body

      expect(json_response['id']).to eq(inventory.id)
      expect(json_response['user_id']).to eq(user.id)
      expect(json_response['bead_id']).to eq(bead.id)
    end

    it 'returns 404 for other user inventory' do
      get "/api/v1/inventories/#{other_user_inventory.id}", headers: headers

      expect(response).to have_http_status(:not_found)
      json_response = response.parsed_body
      expect(json_response['error']).to eq('Inventory item not found')
    end

    it 'returns 404 for non-existent inventory' do
      get '/api/v1/inventories/999999', headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/inventories' do
    let(:valid_params) do
      {
        inventory: {
          bead_id: bead.id,
          quantity: 15.5,
          quantity_unit: 'grams',
        },
      }
    end

    it 'creates a new inventory item' do # rubocop:disable RSpec/MultipleExpectations
      expect do
        post '/api/v1/inventories', params: valid_params.to_json, headers: headers
      end.to change(Inventory, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = response.parsed_body

      expect(json_response['bead_id']).to eq(bead.id)
      expect(json_response['quantity']).to eq('15.5')
      expect(json_response['quantity_unit']).to eq('grams')
      expect(json_response['user_id']).to eq(user.id)
    end

    it 'prevents duplicate inventory entries' do
      create(:inventory, user: user, bead: bead)

      post '/api/v1/inventories', params: valid_params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = response.parsed_body
      expect(json_response['error']).to be_present
    end

    it 'validates required fields' do
      invalid_params = { inventory: { quantity: -5 } } # invalid quantity

      post '/api/v1/inventories', params: invalid_params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/inventories/:id' do
    let!(:inventory) { create(:inventory, user: user, bead: bead, quantity: 10.0, quantity_unit: 'unit') }
    let(:update_params) do
      {
        inventory: {
          quantity: 25.5,
          quantity_unit: 'grams',
        },
      }
    end

    it 'updates the inventory item' do
      patch "/api/v1/inventories/#{inventory.id}", params: update_params.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body

      expect(json_response['quantity']).to eq('25.5')
      expect(json_response['quantity_unit']).to eq('grams')

      inventory.reload
      expect(inventory.quantity).to eq(25.5)
      expect(inventory.quantity_unit).to eq('grams')
    end

    it 'returns 404 for other user inventory' do
      other_inventory = create(:inventory, user: other_user, bead: bead)

      patch "/api/v1/inventories/#{other_inventory.id}", params: update_params.to_json, headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/inventories/:id' do
    let!(:inventory) { create(:inventory, user: user, bead: bead) }

    it 'deletes the inventory item' do
      expect do
        delete "/api/v1/inventories/#{inventory.id}", headers: headers
      end.to change(Inventory, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 for other user inventory' do
      other_inventory = create(:inventory, user: other_user, bead: bead)

      delete "/api/v1/inventories/#{other_inventory.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'authentication' do
    it 'requires authentication for all endpoints' do
      unauthenticated_headers = { 'Content-Type' => 'application/json' }

      get '/api/v1/inventories', headers: unauthenticated_headers
      expect(response.status).to be_in([401, 422]) # Different order in Rails processing

      post '/api/v1/inventories', headers: unauthenticated_headers
      expect(response.status).to be_in([401, 422]) # 422 if params validation fails first
    end
  end
end
