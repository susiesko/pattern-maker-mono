# frozen_string_literal: true

#
# rubocop:disable RSpec/MultipleExpectations

require 'rails_helper'

RSpec.describe "Api::V1::Catalog::BeadTypes", type: :request do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  describe "GET /index" do
    context "when there are no bead types" do
      before do
        get api_v1_catalog_bead_types_path, headers: valid_headers
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

    context "when there are bead types" do
      let(:brand) { create(:bead_brand) }

      before do
        # Create three bead types with the same brand
        create(:bead_type, brand: brand, name: "Type 1")
        create(:bead_type, brand: brand, name: "Type 2")
        create(:bead_type, brand: brand, name: "Type 3")

        get api_v1_catalog_bead_types_path, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns all bead types" do
        expect(json_response[:data].size).to eq(3)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end

      it "includes brand information in the response" do
        expect(json_response[:data].first[:brand]).to be_present
      end
    end

    context "with filtering by brand" do
      let(:first_brand) { create(:bead_brand, name: "First Brand") }
      let(:second_brand) { create(:bead_brand, name: "Second Brand") }

      before do
        # Create two types for first brand
        create(:bead_type, brand: first_brand, name: "Type A for First Brand")
        create(:bead_type, brand: first_brand, name: "Type B for First Brand")

        # Create one type for second brand
        create(:bead_type, brand: second_brand, name: "Type A for Second Brand")
      end

      it "filters types by brand_id" do
        get api_v1_catalog_bead_types_path, params: { brand_id: first_brand.id }, headers: valid_headers
        expect(json_response[:data].size).to eq(2)
        expect(json_response[:data].map { |type| type[:brand_id] }).to all(eq(first_brand.id))
      end
    end
  end

  describe "GET /show" do
    context "when the bead type exists" do
      let!(:bead_type) { create(:bead_type) }
      let!(:bead_sizes) { create_list(:bead_size, 2, type: bead_type, brand: bead_type.brand) }

      before do
        get api_v1_catalog_bead_type_path(bead_type), headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the requested bead type" do
        expect(json_response[:data][:id]).to eq(bead_type.id)
        expect(json_response[:data][:name]).to eq(bead_type.name)
      end

      it "includes brand information" do
        expect(json_response[:data][:brand][:id]).to eq(bead_type.brand.id)
        expect(json_response[:data][:brand][:name]).to eq(bead_type.brand.name)
      end

      it "includes associated bead sizes" do
        expect(json_response[:data][:bead_sizes].size).to eq(2)
        expect(json_response[:data][:bead_sizes].map { |size| size[:id] }).to match_array(bead_sizes.map(&:id))
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead type does not exist" do
      before do
        get api_v1_catalog_bead_type_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead type not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "POST /create" do
    let!(:brand) { create(:bead_brand) }

    context "with valid parameters" do
      let(:valid_attributes) { { bead_type: { name: "New Type", brand_id: brand.id } } }

      before do
        post api_v1_catalog_bead_types_path, params: valid_attributes, headers: valid_headers
      end

      it "returns http created" do
        expect(response).to have_http_status(:created)
      end

      it "creates a new bead type" do
        expect(Catalog::BeadType.count).to eq(1)
        expect(Catalog::BeadType.first.name).to eq("New Type")
      end

      it "associates the type with the specified brand" do
        expect(Catalog::BeadType.first.brand_id).to eq(brand.id)
      end

      it "returns the created bead type" do
        expect(json_response[:data][:name]).to eq("New Type")
        expect(json_response[:data][:brand][:id]).to eq(brand.id)
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead type created successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_type: { name: nil, brand_id: brand.id } } }

      before do
        post api_v1_catalog_bead_types_path, params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new bead type" do
        expect(Catalog::BeadType.count).to eq(0)
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
    let!(:bead_type) { create(:bead_type, name: "Original Name") }
    let!(:new_brand) { create(:bead_brand) }

    context "with valid parameters" do
      let(:updated_attributes) { { bead_type: { name: "Updated Name", brand_id: new_brand.id } } }

      before do
        patch api_v1_catalog_bead_type_path(bead_type), params: updated_attributes, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the bead type" do
        bead_type.reload
        expect(bead_type.name).to eq("Updated Name")
        expect(bead_type.brand_id).to eq(new_brand.id)
      end

      it "returns the updated bead type" do
        expect(json_response[:data][:name]).to eq("Updated Name")
        expect(json_response[:data][:brand][:id]).to eq(new_brand.id)
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead type updated successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_type: { name: nil } } }

      before do
        patch api_v1_catalog_bead_type_path(bead_type), params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the bead type" do
        bead_type.reload
        expect(bead_type.name).to eq("Original Name")
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead type does not exist" do
      before do
        patch api_v1_catalog_bead_type_path(id: 999), params: { bead_type: { name: "Updated Name" } }, headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead type not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "DELETE /destroy" do
    context "when the bead type exists" do
      let!(:bead_type) { create(:bead_type) }

      it "returns http success" do
        delete api_v1_catalog_bead_type_path(bead_type), headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it "deletes the bead type" do
        # Ensure the type exists before deletion
        expect(Catalog::BeadType.exists?(bead_type.id)).to be true

        delete api_v1_catalog_bead_type_path(bead_type), headers: valid_headers

        # Verify it's deleted after the request
        expect(Catalog::BeadType.exists?(bead_type.id)).to be false
      end

      it "returns a success message" do
        delete api_v1_catalog_bead_type_path(bead_type), headers: valid_headers
        expect(json_response[:message]).to eq("Bead type deleted successfully")
      end

      it "returns success status in the response" do
        delete api_v1_catalog_bead_type_path(bead_type), headers: valid_headers
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead type does not exist" do
      before do
        delete api_v1_catalog_bead_type_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead type not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead type has associated records" do
      let!(:bead_type) { create(:bead_type) }
      let!(:bead_size) { create(:bead_size, type: bead_type, brand: bead_type.brand) }

      it "deletes the bead type and associated records" do
        # Ensure both records exist before deletion
        expect(Catalog::BeadType.exists?(bead_type.id)).to be true
        expect(Catalog::BeadSize.exists?(bead_size.id)).to be true

        delete api_v1_catalog_bead_type_path(bead_type), headers: valid_headers

        # Verify both are deleted after the request
        expect(Catalog::BeadType.exists?(bead_type.id)).to be false
        expect(Catalog::BeadSize.exists?(bead_size.id)).to be false
      end
    end
  end
end
