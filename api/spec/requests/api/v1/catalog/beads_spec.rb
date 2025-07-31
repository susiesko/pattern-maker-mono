# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations

require 'rails_helper'

# Shared contexts to reduce the number of let statements in each example group
RSpec.shared_context 'with common request setup' do
  let(:valid_headers) { { 'ACCEPT' => 'application/json' } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }
end

# Helper method to create test data for filtering
def create_filter_test_data
  first_brand = create(:bead_brand)
  second_brand = create(:bead_brand)

  first_bead = create(:bead,
                      brand: first_brand,
                      shape: 'Delica',
                      size: '11/0',
                      color_group: 'red',
                      glass_group: 'Opaque',
                      finish: 'Matte',
                      dyed: 'Dyed',
                      galvanized: 'Non-galvanized',
                      plating: 'Non-plating')

  second_bead = create(:bead,
                       brand: second_brand,
                       shape: 'Rocailles',
                       size: '8/0',
                       color_group: 'blue',
                       glass_group: 'Transparent',
                       finish: 'Glossy',
                       dyed: 'Non-dyed',
                       galvanized: 'Galvanized',
                       plating: 'Plating')

  {
    first_brand: first_brand,
    second_brand: second_brand,
    first_bead: first_bead,
    second_bead: second_bead,
  }
end

# Helper method to create a bead with detailed attributes
def create_bead_with_attributes
  brand = create(:bead_brand)
  bead = create(:bead,
                brand: brand,
                shape: 'Delica',
                size: '11/0',
                color_group: 'red',
                glass_group: 'Opaque',
                finish: 'Matte',
                dyed: 'Dyed',
                galvanized: 'Non-galvanized',
                plating: 'Non-plating')

  {
    bead: bead,
    brand: brand,
  }
end

# Helper method to create data for bead creation tests
def create_bead_creation_data
  brand = create(:bead_brand)

  {
    brand: brand,
    valid_attributes: {
      bead: {
        name: 'New Bead',
        brand_product_code: 'NB-001',
        brand_id: brand.id,
        shape: 'Delica',
        size: '11/0',
        color_group: 'red',
        glass_group: 'Opaque',
        finish: 'Matte',
        dyed: 'Dyed',
        galvanized: 'Non-galvanized',
        plating: 'Non-plating',
        metadata: { material: 'glass' },
      },
    },
    invalid_attributes: {
      bead: {
        name: nil,
        brand_product_code: 'NB-001',
        brand_id: brand.id,
      },
    },
  }
end

# Helper method to create data for bead update tests
def create_bead_update_data
  brand = create(:bead_brand)
  bead = create(:bead,
                name: 'Original Name',
                brand: brand,
                shape: 'Delica',
                size: '11/0',
                color_group: 'red')

  {
    bead: bead,
    brand: brand,
    valid_attributes: {
      bead: {
        name: 'Updated Name',
        shape: 'Rocailles',
        size: '8/0',
        color_group: 'blue',
      },
    },
    invalid_attributes: {
      bead: { name: nil },
    },
  }
end

# Helper method to create data for bead deletion tests
def create_bead_deletion_data
  brand = create(:bead_brand)
  bead = create(:bead,
                brand: brand,
                shape: 'Delica',
                size: '11/0',
                color_group: 'red')

  {
    bead: bead,
    brand: brand,
  }
end

RSpec.describe 'Api::V1::Catalog::Beads', type: :request do
  include_context 'with common request setup'

  describe 'GET /index' do
    context 'when there are no beads' do
      before do
        get api_v1_catalog_beads_path, headers: valid_headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns an empty data array' do
        expect(json_response[:data]).to be_empty
      end

      it 'returns success status in the response' do
        expect(json_response[:success]).to be true
      end
    end

    context 'when there are beads' do
      let(:index_beads) { create_list(:bead, 3) }

      before do
        index_beads # ensure beads are created
        get api_v1_catalog_beads_path, headers: valid_headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns all beads' do
        expect(json_response[:data].size).to eq(3)
      end

      it 'returns success status in the response' do
        expect(json_response[:success]).to be true
      end

      it 'includes brand in the response' do
        expect(json_response[:data].first).to have_key(:brand)
      end

      it 'does not include user_inventory when unauthenticated' do
        expect(json_response[:data].first).not_to have_key(:user_inventory)
      end
    end

    context 'when user is authenticated' do
      let(:user) { create(:user) }
      let(:token) { AuthenticationService.encode(user_id: user.id) }
      let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }
      let!(:beads) { create_list(:bead, 2) }
      let!(:inventory) { create(:inventory, user: user, bead: beads.first, quantity: 10, quantity_unit: 'unit') }

      it 'includes user_inventory for beads in user inventory' do
        get api_v1_catalog_beads_path, headers: headers
        expect(response).to have_http_status(:success)
        data = response.parsed_body['data']
        bead_with_inventory = data.find { |b| b['id'] == beads.first.id }
        bead_without_inventory = data.find { |b| b['id'] == beads.second.id }
        expect(bead_with_inventory['user_inventory']).to be_present
        expect(bead_with_inventory['user_inventory']['id']).to eq(inventory.id)
        expect(bead_with_inventory['user_inventory']['quantity']).to eq('10.0')
        expect(bead_with_inventory['user_inventory']['quantity_unit']).to eq('unit')
        expect(bead_without_inventory['user_inventory']).to be_nil
      end
    end

    context 'with pagination' do
      before do
        create_list(:bead, 25)
        get api_v1_catalog_beads_path, params: { page: 1, per_page: 10 }, headers: valid_headers
      end

      it 'returns paginated results' do
        expect(json_response[:data].size).to eq(10)
        expect(json_response[:pagination]).to be_present
        expect(json_response[:pagination][:current_page]).to eq(1)
        expect(json_response[:pagination][:per_page]).to eq(10)
      end
    end
  end

  describe 'GET /show' do
    context 'when the bead exists' do
      # Use a single let statement with the helper method
      let(:show_data) { create_bead_with_attributes }

      before do
        get api_v1_catalog_bead_path(show_data[:bead]), headers: valid_headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the requested bead' do
        expect(json_response[:data][:id]).to eq(show_data[:bead].id)
        expect(json_response[:data][:name]).to eq(show_data[:bead].name)
      end

      it 'includes brand in the response' do
        expect(json_response[:data][:brand][:id]).to eq(show_data[:bead].brand.id)
      end

      it 'includes shape in the response' do
        expect(json_response[:data][:shape]).to eq(show_data[:bead].shape)
      end

      it 'includes size in the response' do
        expect(json_response[:data][:size]).to eq(show_data[:bead].size)
      end

      it 'includes color_group in the response' do
        expect(json_response[:data][:color_group]).to eq(show_data[:bead].color_group)
      end

      it 'includes glass_group in the response' do
        expect(json_response[:data][:glass_group]).to eq(show_data[:bead].glass_group)
      end

      it 'includes finish in the response' do
        expect(json_response[:data][:finish]).to eq(show_data[:bead].finish)
      end

      it 'includes dyed in the response' do
        expect(json_response[:data][:dyed]).to eq(show_data[:bead].dyed)
      end

      it 'includes galvanized in the response' do
        expect(json_response[:data][:galvanized]).to eq(show_data[:bead].galvanized)
      end

      it 'includes plating in the response' do
        expect(json_response[:data][:plating]).to eq(show_data[:bead].plating)
      end

      it 'returns success status in the response' do
        expect(json_response[:success]).to be true
      end
    end

    context 'when the bead does not exist' do
      before do
        get api_v1_catalog_bead_path(id: 999), headers: valid_headers
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(json_response[:errors]).to include('Bead not found')
      end

      it 'returns failure status in the response' do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe 'POST /create' do
    # Use a single let statement with the helper method
    let(:create_data) { create_bead_creation_data }

    context 'with valid parameters' do
      before do
        post api_v1_catalog_beads_path, params: create_data[:valid_attributes], headers: valid_headers
      end

      it 'returns http created' do
        expect(response).to have_http_status(:created)
      end

      it 'creates a new bead' do
        expect(Catalog::Bead.count).to eq(1)
        expect(Catalog::Bead.first.name).to eq('New Bead')
      end

      it 'associates the bead with the specified attributes' do
        expect(Catalog::Bead.first.shape).to eq(create_data[:valid_attributes][:bead][:shape])
        expect(Catalog::Bead.first.size).to eq(create_data[:valid_attributes][:bead][:size])
        expect(Catalog::Bead.first.color_group).to eq(create_data[:valid_attributes][:bead][:color_group])
        expect(Catalog::Bead.first.glass_group).to eq(create_data[:valid_attributes][:bead][:glass_group])
        expect(Catalog::Bead.first.finish).to eq(create_data[:valid_attributes][:bead][:finish])
        expect(Catalog::Bead.first.dyed).to eq(create_data[:valid_attributes][:bead][:dyed])
        expect(Catalog::Bead.first.galvanized).to eq(create_data[:valid_attributes][:bead][:galvanized])
        expect(Catalog::Bead.first.plating).to eq(create_data[:valid_attributes][:bead][:plating])
      end

      it 'returns the created bead' do
        expect(json_response[:data][:name]).to eq('New Bead')
        expect(json_response[:data][:brand_product_code]).to eq('NB-001')
        expect(json_response[:data][:type]).to be_nil # Removed type as it's no longer a polymorphic association
      end

      it 'returns a success message' do
        expect(json_response[:message]).to eq('Bead created successfully')
      end

      it 'returns success status in the response' do
        expect(json_response[:success]).to be true
      end
    end

    context 'with invalid parameters' do
      before do
        post api_v1_catalog_beads_path, params: create_data[:invalid_attributes], headers: valid_headers
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a new bead' do
        expect(Catalog::Bead.count).to eq(0)
      end

      it 'returns an error message' do
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it 'returns failure status in the response' do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe 'PATCH /update' do
    # Use a single let statement with the helper method
    let(:update_data) { create_bead_update_data }

    context 'with valid parameters' do
      before do
        patch api_v1_catalog_bead_path(update_data[:bead]), params: update_data[:valid_attributes], headers: valid_headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates the bead' do
        update_data[:bead].reload
        expect(update_data[:bead].name).to eq('Updated Name')
        expect(update_data[:bead].shape).to eq(update_data[:valid_attributes][:bead][:shape])
        expect(update_data[:bead].size).to eq(update_data[:valid_attributes][:bead][:size])
        expect(update_data[:bead].color_group).to eq(update_data[:valid_attributes][:bead][:color_group])
      end

      it 'returns the updated bead' do
        expect(json_response[:data][:name]).to eq('Updated Name')
      end

      it 'returns a success message' do
        expect(json_response[:message]).to eq('Bead updated successfully')
      end

      it 'returns success status in the response' do
        expect(json_response[:success]).to be true
      end
    end

    context 'with invalid parameters' do
      before do
        patch api_v1_catalog_bead_path(update_data[:bead]), params: update_data[:invalid_attributes], headers: valid_headers
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update the bead' do
        update_data[:bead].reload
        expect(update_data[:bead].name).to eq('Original Name')
      end

      it 'returns an error message' do
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it 'returns failure status in the response' do
        expect(json_response[:success]).to be false
      end
    end

    context 'when the bead does not exist' do
      before do
        patch api_v1_catalog_bead_path(id: 999), params: { bead: { name: 'Updated Name' } }, headers: valid_headers
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(json_response[:errors]).to include('Bead not found')
      end

      it 'returns failure status in the response' do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when the bead exists' do
      # Use a single let statement with the helper method
      let(:delete_data) { create_bead_deletion_data }

      it 'returns http success' do
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it 'deletes the bead' do
        bead_id = delete_data[:bead].id
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(Catalog::Bead.find_by(id: bead_id)).to be_nil
      end

      it 'returns a success message' do
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(json_response[:message]).to eq('Bead deleted successfully')
      end

      it 'returns success status in the response' do
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(json_response[:success]).to be true
      end
    end

    context 'when the bead does not exist' do
      before do
        delete api_v1_catalog_bead_path(id: 999), headers: valid_headers
      end

      it 'returns http not found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(json_response[:errors]).to include('Bead not found')
      end

      it 'returns failure status in the response' do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe 'GET /api/v1/catalog/beads/:id' do
    let(:test_bead) { create(:bead) }

    context 'when user is authenticated' do
      let(:user) { create(:user) }
      let(:token) { AuthenticationService.encode(user_id: user.id) }
      let(:headers) { { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{token}" } }

      context 'when user has inventory for the bead' do
        let!(:inventory) { create(:inventory, user: user, bead: test_bead, quantity: 25.5, quantity_unit: 'grams') }

        it 'includes user inventory information' do
          get "/api/v1/catalog/beads/#{test_bead.id}", headers: headers

          expect(response).to have_http_status(:ok)
          json_response = response.parsed_body

          expect(json_response['success']).to be true
          bead_data = json_response['data']
          expect(bead_data['user_inventory']).to be_present
          expect(bead_data['user_inventory']['id']).to eq(inventory.id)
          expect(bead_data['user_inventory']['quantity']).to eq('25.5')
          expect(bead_data['user_inventory']['quantity_unit']).to eq('grams')
        end
      end

      context 'when user has no inventory for the bead' do
        it 'includes null user inventory' do
          get "/api/v1/catalog/beads/#{test_bead.id}", headers: headers

          expect(response).to have_http_status(:ok)
          json_response = response.parsed_body

          expect(json_response['success']).to be true
          bead_data = json_response['data']
          expect(bead_data['user_inventory']).to be_nil
        end
      end
    end

    context 'when user is not authenticated' do
      it 'does not include user inventory information' do
        get "/api/v1/catalog/beads/#{test_bead.id}"

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body

        expect(json_response['success']).to be true
        bead_data = json_response['data']
        expect(bead_data).not_to have_key('user_inventory')
      end
    end
  end
end

# rubocop:enable RSpec/MultipleExpectations
