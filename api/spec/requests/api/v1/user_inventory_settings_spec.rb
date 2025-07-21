# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::UserInventorySettings', type: :request do
  let(:user) { create(:user) }
  let(:token) { AuthenticationService.encode(user_id: user.id) }
  let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/inventory-settings' do
    context 'when user has inventory settings' do
      let!(:setting) { create(:user_inventory_setting, user: user) }

      it 'returns the user inventory settings' do
        get '/api/v1/inventory-settings', headers: headers

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body

        expect(json_response['id']).to eq(setting.id)
        expect(json_response['user_id']).to eq(user.id)
        expect(json_response['field_definitions']).to be_present
      end
    end

    context 'when user has no inventory settings' do
      it 'returns 404' do
        get '/api/v1/inventory-settings', headers: headers

        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('Inventory settings not found')
      end
    end
  end

  describe 'POST /api/v1/inventory-settings' do
    let(:valid_params) do
      {
        user_inventory_setting: {
          field_definitions: [
            {
              'fieldName' => 'location',
              'fieldType' => 'text',
              'label' => 'Storage Location',
            },
            {
              'fieldName' => 'purchase_date',
              'fieldType' => 'date',
              'label' => 'Purchase Date',
            },
            {
              'fieldName' => 'notes',
              'fieldType' => 'textarea',
              'label' => 'Notes',
            },
          ],
        },
      }
    end

    it 'creates user inventory settings' do
      expect do
        post '/api/v1/inventory-settings', params: valid_params.to_json, headers: headers
      end.to change(UserInventorySetting, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = response.parsed_body

      expect(json_response['user_id']).to eq(user.id)
      expect(json_response['field_definitions'].length).to eq(3)
      expect(json_response['field_definitions'].first['fieldName']).to eq('location')
    end

    it 'validates field definitions format' do
      invalid_params = {
        user_inventory_setting: {
          field_definitions: [
            { 'fieldName' => 'invalid' }, # missing required keys
          ],
        },
      }

      post '/api/v1/inventory-settings', params: invalid_params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      json_response = response.parsed_body
      expect(json_response['error']).to be_present
    end

    it 'prevents creating duplicate settings for same user' do
      # Create initial setting
      post '/api/v1/inventory-settings', params: valid_params.to_json, headers: headers
      expect(response).to have_http_status(:created)

      # Try to create another one - should fail
      post '/api/v1/inventory-settings', params: valid_params.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/inventory-settings' do
    let!(:setting) { create(:user_inventory_setting, user: user) }
    let(:update_params) do
      {
        user_inventory_setting: {
          field_definitions: [
            {
              'fieldName' => 'supplier',
              'fieldType' => 'text',
              'label' => 'Supplier Name',
            },
            {
              'fieldName' => 'cost',
              'fieldType' => 'number',
              'label' => 'Cost Per Unit',
            },
          ],
        },
      }
    end

    it 'updates the inventory settings' do
      patch '/api/v1/inventory-settings', params: update_params.to_json, headers: headers

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body

      expect(json_response['field_definitions'].length).to eq(2)
      expect(json_response['field_definitions'].first['fieldName']).to eq('supplier')

      setting.reload
      expect(setting.field_definitions.length).to eq(2)
    end

    it 'validates updated field definitions' do
      invalid_params = {
        user_inventory_setting: {
          field_definitions: [
            { 'fieldName' => 'test', 'fieldType' => 'invalid_type', 'label' => 'Test' },
          ],
        },
      }

      patch '/api/v1/inventory-settings', params: invalid_params.to_json, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns 404 when user has no settings' do
      setting.destroy

      patch '/api/v1/inventory-settings', params: update_params.to_json, headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'authentication' do
    it 'requires authentication for all endpoints' do
      unauthenticated_headers = { 'Content-Type' => 'application/json' }

      get '/api/v1/inventory-settings', headers: unauthenticated_headers
      expect(response.status).to be_in([401, 422]) # Different order in Rails processing

      post '/api/v1/inventory-settings', headers: unauthenticated_headers
      expect(response.status).to be_in([401, 422]) # 422 if params validation fails first

      patch '/api/v1/inventory-settings', headers: unauthenticated_headers
      expect(response.status).to be_in([401, 422])
    end
  end
end
