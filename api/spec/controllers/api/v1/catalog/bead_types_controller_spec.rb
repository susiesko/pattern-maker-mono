require 'rails_helper'

RSpec.describe Api::V1::Catalog::BeadTypesController, type: :controller do
  let!(:brand) { create(:bead_brand) }
  let!(:bead_types) { create_list(:bead_type, 10, brand: brand) }
  let(:bead_type_id) { bead_types.first.id }
  
  describe "GET #index" do
    before { get :index }
    
    it "returns a successful response" do
      expect(response).to be_successful
    end
    
    it "returns bead types in the response" do
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('bead_types')
      expect(json_response['bead_types'].size).to eq(10)
    end
    
    it "includes pagination metadata" do
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('meta')
      expect(json_response['meta']).to include('current_page', 'total_count')
    end
    
    context "with filtering parameters" do
      it "filters by brand_id" do
        get :index, params: { brand_id: brand.id }
        json_response = JSON.parse(response.body)
        expect(json_response['bead_types'].size).to eq(10)
      end
      
      it "filters by search term" do
        search_term = bead_types.first.name[0..2]
        get :index, params: { search: search_term }
        json_response = JSON.parse(response.body)
        expect(json_response['bead_types'].size).to be > 0
      end
      
      it "sorts by name" do
        get :index, params: { sort_by: 'name', sort_direction: 'asc' }
        json_response = JSON.parse(response.body)
        names = json_response['bead_types'].map { |bt| bt['name'] }
        expect(names).to eq(names.sort)
      end
      
      it "paginates results" do
        get :index, params: { page: 1, items: 5 }
        json_response = JSON.parse(response.body)
        expect(json_response['bead_types'].size).to eq(5)
        expect(json_response['meta']['current_page']).to eq(1)
      end
    end
  end
  
  describe "GET #show" do
    context "when the record exists" do
      before { get :show, params: { id: bead_type_id } }
      
      it "returns a successful response" do
        expect(response).to be_successful
      end
      
      it "returns the bead type in the response" do
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(bead_type_id)
      end
      
      it "includes the brand information" do
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('brand')
        expect(json_response['brand']['id']).to eq(brand.id)
      end
    end
    
    context "when the record does not exist" do
      before { get :show, params: { id: 999 } }
      
      it "returns a 404 status code" do
        expect(response).to have_http_status(:not_found)
      end
      
      it "returns an error message" do
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
        expect(json_response['error']).to match(/not found/)
      end
    end
  end
end