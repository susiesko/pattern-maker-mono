# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Catalog::Beads Sorting', type: :request do
  let(:valid_headers) { { 'ACCEPT' => 'application/json' } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  before do
    # Create beads with different values for sorting
    create(:bead, brand_product_code: 'Z-999', name: 'Alpha Bead')
    create(:bead, brand_product_code: 'A-001', name: 'Zeta Bead')
    create(:bead, brand_product_code: 'M-500', name: 'Beta Bead')
  end

  describe 'GET /api/v1/catalog/beads' do
    context 'with no sort parameters' do
      it 'defaults to sorting by id descending' do
        get api_v1_catalog_beads_path, headers: valid_headers

        expect(response).to have_http_status(:ok)
        data = json_response[:data]

        # Should be sorted by id descending (newest first)
        ids = data.map { |bead| bead[:id] }
        expect(ids).to eq(ids.sort.reverse)
      end
    end

    context 'with sort_by=product_code' do
      it 'sorts by brand_product_code ascending' do
        get api_v1_catalog_beads_path, params: { sort_by: 'product_code', direction: 'asc' }, headers: valid_headers

        expect(response).to have_http_status(:ok)
        data = json_response[:data]

        product_codes = data.map { |bead| bead[:brand_product_code] }
        expect(product_codes).to eq(%w[A-001 M-500 Z-999])
      end
    end

    context 'with sort_by=name' do
      it 'sorts by name ascending' do
        get api_v1_catalog_beads_path, params: { sort_by: 'name', direction: 'asc' }, headers: valid_headers

        expect(response).to have_http_status(:ok)
        data = json_response[:data]

        names = data.map { |bead| bead[:name] }
        expect(names).to eq(['Alpha Bead', 'Beta Bead', 'Zeta Bead'])
      end
    end

    context 'with invalid sort_by' do
      it 'defaults to id sorting' do
        get api_v1_catalog_beads_path, params: { sort_by: 'invalid_field' }, headers: valid_headers

        expect(response).to have_http_status(:ok)
        data = json_response[:data]

        ids = data.map { |bead| bead[:id] }
        expect(ids).to eq(ids.sort.reverse)
      end
    end
  end
end
