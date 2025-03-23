# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations

require 'rails_helper'

RSpec.describe "Api::V1::Catalog::BeadSizes", type: :request do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  describe "GET /index" do
    context "when there are no bead sizes" do
      before do
        get api_v1_catalog_bead_sizes_path, headers: valid_headers
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

    context "when there are bead sizes" do
      let(:brand) { create(:bead_brand) }
      let(:type) { create(:bead_type, brand: brand) }

      before do
        # Create three bead sizes
        create(:bead_size, brand: brand, type: type, size: "Small")
        create(:bead_size, brand: brand, type: type, size: "Medium")
        create(:bead_size, brand: brand, type: type, size: "Large")

        get api_v1_catalog_bead_sizes_path, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns all bead sizes" do
        expect(json_response[:data].size).to eq(3)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end

      it "includes brand and type information in the response" do
        expect(json_response[:data].first[:brand]).to be_present
        expect(json_response[:data].first[:type]).to be_present
      end
    end

    context "with filtering" do
      let(:first_brand) { create(:bead_brand, name: "First Brand") }
      let(:second_brand) { create(:bead_brand, name: "Second Brand") }
      let(:first_type) { create(:bead_type, brand: first_brand, name: "First Type") }
      let(:second_type) { create(:bead_type, brand: second_brand, name: "Second Type") }

      before do
        # Create two sizes for first brand and first type
        create(:bead_size, brand: first_brand, type: first_type, size: "Small for First")
        create(:bead_size, brand: first_brand, type: first_type, size: "Medium for First")

        # Create one size for second brand and second type
        create(:bead_size, brand: second_brand, type: second_type, size: "Small for Second")
      end

      it "filters sizes by brand_id" do
        get api_v1_catalog_bead_sizes_path, params: { brand_id: first_brand.id }, headers: valid_headers
        expect(json_response[:data].size).to eq(2)
        expect(json_response[:data].map { |size| size[:brand_id] }).to all(eq(first_brand.id))
      end

      it "filters sizes by type_id" do
        get api_v1_catalog_bead_sizes_path, params: { type_id: first_type.id }, headers: valid_headers
        expect(json_response[:data].size).to eq(2)
        expect(json_response[:data].map { |size| size[:type_id] }).to all(eq(first_type.id))
      end
    end
  end

  describe "GET /show" do
    context "when the bead size exists" do
      let!(:bead_size) { create(:bead_size) }

      before do
        get api_v1_catalog_bead_size_path(bead_size), headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the requested bead size" do
        expect(json_response[:data][:id]).to eq(bead_size.id)
        expect(json_response[:data][:size]).to eq(bead_size.size)
      end

      it "includes brand information" do
        expect(json_response[:data][:brand][:id]).to eq(bead_size.brand.id)
        expect(json_response[:data][:brand][:name]).to eq(bead_size.brand.name)
      end

      it "includes type information" do
        expect(json_response[:data][:type][:id]).to eq(bead_size.type.id)
        expect(json_response[:data][:type][:name]).to eq(bead_size.type.name)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead size does not exist" do
      before do
        get api_v1_catalog_bead_size_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead size not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "POST /create" do
    let!(:brand) { create(:bead_brand) }
    let!(:type) { create(:bead_type, brand: brand) }

    context "with valid parameters" do
      let(:valid_attributes) {
        {
          bead_size: {
            size: "3mm",
            brand_id: brand.id,
            type_id: type.id,
            metadata: { diameter: "3mm", weight: "0.1g" }
          }
        }
      }

      before do
        post api_v1_catalog_bead_sizes_path, params: valid_attributes, headers: valid_headers
      end

      it "returns http created" do
        expect(response).to have_http_status(:created)
      end

      it "creates a new bead size" do
        expect(Catalog::BeadSize.count).to eq(1)
        expect(Catalog::BeadSize.first.size).to eq("3mm")
      end

      it "associates the size with the specified brand and type" do
        expect(Catalog::BeadSize.first.brand_id).to eq(brand.id)
        expect(Catalog::BeadSize.first.type_id).to eq(type.id)
      end

      it "stores the metadata" do
        expect(Catalog::BeadSize.first.metadata).to include("diameter" => "3mm", "weight" => "0.1g")
      end

      it "returns the created bead size" do
        expect(json_response[:data][:size]).to eq("3mm")
        expect(json_response[:data][:brand][:id]).to eq(brand.id)
        expect(json_response[:data][:type][:id]).to eq(type.id)
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead size created successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_size: { size: nil, brand_id: brand.id, type_id: type.id } } }

      before do
        post api_v1_catalog_bead_sizes_path, params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new bead size" do
        expect(Catalog::BeadSize.count).to eq(0)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Size can't be blank")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "PATCH /update" do
    let!(:bead_size) { create(:bead_size, size: "Original Size") }
    let!(:new_brand) { create(:bead_brand) }
    let!(:new_type) { create(:bead_type, brand: new_brand) }

    context "with valid parameters" do
      let(:updated_attributes) {
        {
          bead_size: {
            size: "Updated Size",
            brand_id: new_brand.id,
            type_id: new_type.id,
            metadata: { diameter: "4mm", weight: "0.2g" }
          }
        }
      }

      before do
        patch api_v1_catalog_bead_size_path(bead_size), params: updated_attributes, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the bead size" do
        bead_size.reload
        expect(bead_size.size).to eq("Updated Size")
        expect(bead_size.brand_id).to eq(new_brand.id)
        expect(bead_size.type_id).to eq(new_type.id)
        expect(bead_size.metadata).to include("diameter" => "4mm", "weight" => "0.2g")
      end

      it "returns the updated bead size" do
        expect(json_response[:data][:size]).to eq("Updated Size")
        expect(json_response[:data][:brand][:id]).to eq(new_brand.id)
        expect(json_response[:data][:type][:id]).to eq(new_type.id)
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead size updated successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_size: { size: nil } } }

      before do
        patch api_v1_catalog_bead_size_path(bead_size), params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the bead size" do
        bead_size.reload
        expect(bead_size.size).to eq("Original Size")
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Size can't be blank")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead size does not exist" do
      before do
        patch api_v1_catalog_bead_size_path(id: 999), params: { bead_size: { size: "Updated Size" } }, headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead size not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "DELETE /destroy" do
    context "when the bead size exists" do
      let!(:bead_size) { create(:bead_size) }

      it "returns http success" do
        delete api_v1_catalog_bead_size_path(bead_size), headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it "deletes the bead size" do
        # Ensure the size exists before deletion
        expect(Catalog::BeadSize.exists?(bead_size.id)).to be true

        delete api_v1_catalog_bead_size_path(bead_size), headers: valid_headers

        # Verify it's deleted after the request
        expect(Catalog::BeadSize.exists?(bead_size.id)).to be false
      end

      it "returns a success message" do
        delete api_v1_catalog_bead_size_path(bead_size), headers: valid_headers
        expect(json_response[:message]).to eq("Bead size deleted successfully")
      end

      it "returns success status in the response" do
        delete api_v1_catalog_bead_size_path(bead_size), headers: valid_headers
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead size does not exist" do
      before do
        delete api_v1_catalog_bead_size_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead size not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead size has associated records" do
      let!(:bead_size) { create(:bead_size) }
      let!(:bead) { create(:bead, size: bead_size, brand: bead_size.brand) }

      it "deletes the bead size and associated records" do
        # Ensure both records exist before deletion
        expect(Catalog::BeadSize.exists?(bead_size.id)).to be true
        expect(Catalog::Bead.exists?(bead.id)).to be true

        delete api_v1_catalog_bead_size_path(bead_size), headers: valid_headers

        # Verify both are deleted after the request
        expect(Catalog::BeadSize.exists?(bead_size.id)).to be false
        expect(Catalog::Bead.exists?(bead.id)).to be false
      end
    end
  end
end
