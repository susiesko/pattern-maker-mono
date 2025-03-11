# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Catalog::BeadTypes', type: :request do
  let!(:brand) { create(:bead_brand, name: 'Miyuki') }
  let!(:bead_types) { create_list(:bead_type, 10, brand: brand) }
  let(:bead_type_id) { bead_types.first.id }

  describe 'GET /api/v1/catalog/types' do
    before { get '/api/v1/catalog/types' }

    it 'returns bead types' do
      expect(json).not_to be_empty
      expect(json['bead_types'].size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'includes pagination metadata' do
      expect(json['meta']).to include('current_page', 'total_count')
    end
  end

  describe 'GET /api/v1/catalog/types/:id' do
    before { get "/api/v1/catalog/types/#{bead_type_id}" }

    context 'when the record exists' do
      it 'returns the bead type' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(bead_type_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:bead_type_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(json['error']).to match(/Bead type not found/)
      end
    end
  end

  describe 'filtering' do
    context 'by brand' do
      before { get "/api/v1/catalog/types?brand_id=#{brand.id}" }

      it 'returns bead types with the specified brand' do
        expect(json['bead_types']).not_to be_empty
        json['bead_types'].each do |bead_type|
          expect(bead_type['brand']['id']).to eq(brand.id)
        end
      end
    end

    context 'by search term' do
      let(:search_term) { bead_types.first.name[0..2] }
      before { get "/api/v1/catalog/types?search=#{search_term}" }

      it 'returns bead types matching the search term' do
        expect(json['bead_types']).not_to be_empty
        json['bead_types'].each do |bead_type|
          expect(bead_type['name'].downcase).to include(search_term.downcase)
        end
      end
    end

    context 'with sorting' do
      before { get '/api/v1/catalog/types?sort_by=name&sort_direction=asc' }

      it 'returns bead types sorted by name' do
        expect(json['bead_types']).not_to be_empty
        names = json['bead_types'].map { |bt| bt['name'] }
        expect(names).to eq(names.sort)
      end
    end

    context 'with pagination' do
      before { get '/api/v1/catalog/types?page=1&items=5' }

      it 'returns the specified number of items' do
        expect(json['bead_types'].size).to eq(5)
      end

      it 'includes correct pagination metadata' do
        expect(json['meta']['current_page']).to eq(1)
        expect(json['meta']['per_page']).to eq(5)
        expect(json['meta']['total_count']).to eq(10)
      end
    end
  end

  # Helper method to parse JSON responses
  def json
    JSON.parse(response.body)
  end
end
