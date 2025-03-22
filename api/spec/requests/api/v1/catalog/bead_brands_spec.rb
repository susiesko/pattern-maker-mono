# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations

require 'rails_helper'

RSpec.describe "Api::V1::Catalog::BeadBrands", type: :request do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  describe "GET /index" do
    context "when there are no bead brands" do
      before do
        get api_v1_catalog_bead_brands_path, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns an empty data array" do
        expect(json_response[:data]).to be_empty
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "when there are bead brands" do
      before do
        create_list(:bead_brand, 3)
        get api_v1_catalog_bead_brands_path, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns all bead brands" do
        expect(json_response[:data].size).to eq(3)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end

      it "returns brands ordered by name" do
        expect(json_response[:data].map { |brand| brand[:name] }).to eq(Catalog::BeadBrand.order(:name).pluck(:name))
      end
    end
  end

  describe "GET /show" do
    context "when the bead brand exists" do
      let!(:bead_brand) { create(:bead_brand) }
      let!(:bead_types) { create_list(:bead_type, 2, brand: bead_brand) }

      before do
        get api_v1_catalog_bead_brand_path(bead_brand), headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the requested bead brand" do
        expect(json_response[:data][:id]).to eq(bead_brand.id)
        expect(json_response[:data][:name]).to eq(bead_brand.name)
      end

      it "includes associated bead types" do
        expect(json_response[:data][:bead_types].size).to eq(2)
        expect(json_response[:data][:bead_types].map { |type| type[:id] }).to match_array(bead_types.map(&:id))
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead brand does not exist" do
      before do
        get api_v1_catalog_bead_brand_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead brand not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { bead_brand: { name: "New Brand", website: "https://example.com" } } }

      before do
        post api_v1_catalog_bead_brands_path, params: valid_attributes, headers: valid_headers
      end

      it "returns http created" do
        expect(response).to have_http_status(:created)
      end

      it "creates a new bead brand" do
        expect(Catalog::BeadBrand.count).to eq(1)
        expect(Catalog::BeadBrand.first.name).to eq("New Brand")
      end

      it "returns the created bead brand" do
        expect(json_response[:data][:name]).to eq("New Brand")
        expect(json_response[:data][:website]).to eq("https://example.com")
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead brand created successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_brand: { name: nil, website: "https://example.com" } } }

      before do
        post api_v1_catalog_bead_brands_path, params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new bead brand" do
        expect(Catalog::BeadBrand.count).to eq(0)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "PATCH /update" do
    let(:bead_brand) { create(:bead_brand, name: "Original Name") }

    context "with valid parameters" do
      let(:updated_attributes) { { bead_brand: { name: "Updated Name" } } }

      before do
        patch api_v1_catalog_bead_brand_path(bead_brand), params: updated_attributes, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the bead brand" do
        bead_brand.reload
        expect(bead_brand.name).to eq("Updated Name")
      end

      it "returns the updated bead brand" do
        expect(json_response[:data][:name]).to eq("Updated Name")
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead brand updated successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_brand: { name: nil } } }

      before do
        patch api_v1_catalog_bead_brand_path(bead_brand), params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the bead brand" do
        bead_brand.reload
        expect(bead_brand.name).to eq("Original Name")
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end


    context "when the bead brand does not exist" do
      before do
        patch api_v1_catalog_bead_brand_path(id: 999), params: { bead_brand: { name: "Updated Name" } }, headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead brand not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "DELETE /destroy" do
    context "when the bead brand exists" do
      # Use let! to ensure the brand is created immediately
      let!(:bead_brand) { create(:bead_brand) }

      it "returns http success" do
        delete api_v1_catalog_bead_brand_path(bead_brand), headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it "deletes the bead brand" do
        # Ensure the brand exists before deletion
        expect(Catalog::BeadBrand.exists?(bead_brand.id)).to be true

        delete api_v1_catalog_bead_brand_path(bead_brand), headers: valid_headers

        # Verify it's deleted after the request
        expect(Catalog::BeadBrand.exists?(bead_brand.id)).to be false
      end

      it "returns a success message" do
        delete api_v1_catalog_bead_brand_path(bead_brand), headers: valid_headers
        expect(json_response[:message]).to eq("Bead brand deleted successfully")
      end

      it "returns success status in the response" do
        delete api_v1_catalog_bead_brand_path(bead_brand), headers: valid_headers
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead brand does not exist" do
      before do
        delete api_v1_catalog_bead_brand_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead brand not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead brand has associated records" do
      # Use let! for both to ensure immediate creation
      let!(:bead_brand) { create(:bead_brand) }
      let!(:bead_type) { create(:bead_type, brand: bead_brand) }

      it "deletes the bead brand and associated records" do
        # Ensure both records exist before deletion
        expect(Catalog::BeadBrand.exists?(bead_brand.id)).to be true
        expect(Catalog::BeadType.exists?(bead_type.id)).to be true

        delete api_v1_catalog_bead_brand_path(bead_brand), headers: valid_headers

        # Verify both are deleted after the request
        expect(Catalog::BeadBrand.exists?(bead_brand.id)).to be false
        expect(Catalog::BeadType.exists?(bead_type.id)).to be false
      end
    end
  end
end
