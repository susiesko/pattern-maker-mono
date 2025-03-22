# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations

require 'rails_helper'

RSpec.describe "Api::V1::Catalog::BeadColors", type: :request do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  describe "GET /index" do
    context "when there are no bead colors" do
      before do
        get api_v1_catalog_bead_colors_path, headers: valid_headers
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

    context "when there are bead colors" do
      before do
        # Create three bead colors
        create(:bead_color, name: "Red")
        create(:bead_color, name: "Green")
        create(:bead_color, name: "Blue")

        get api_v1_catalog_bead_colors_path, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns all bead colors" do
        expect(json_response[:data].size).to eq(3)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end
  end

  describe "GET /show" do
    context "when the bead color exists" do
      let(:bead_color) { create(:bead_color) }
      let(:bead) { create(:bead) }

      before do
        # Create the association between bead and color
        create(:bead_color_link, bead: bead, color: bead_color)

        get api_v1_catalog_bead_color_path(bead_color), headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the requested bead color" do
        expect(json_response[:data][:id]).to eq(bead_color.id)
        expect(json_response[:data][:name]).to eq(bead_color.name)
      end

      it "includes associated beads" do
        expect(json_response[:data][:beads]).to be_present
        expect(json_response[:data][:beads].first[:id]).to eq(bead.id)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead color does not exist" do
      before do
        get api_v1_catalog_bead_color_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead color not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { bead_color: { name: "New Color" } } }

      before do
        post api_v1_catalog_bead_colors_path, params: valid_attributes, headers: valid_headers
      end

      it "returns http created" do
        expect(response).to have_http_status(:created)
      end

      it "creates a new bead color" do
        expect(Catalog::BeadColor.count).to eq(1)
        expect(Catalog::BeadColor.first.name).to eq("New Color")
      end

      it "returns the created bead color" do
        expect(json_response[:data][:name]).to eq("New Color")
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead color created successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_color: { name: nil } } }

      before do
        post api_v1_catalog_bead_colors_path, params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new bead color" do
        expect(Catalog::BeadColor.count).to eq(0)
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
    let!(:bead_color) { create(:bead_color, name: "Original Color") }

    context "with valid parameters" do
      let(:updated_attributes) { { bead_color: { name: "Updated Color" } } }

      before do
        patch api_v1_catalog_bead_color_path(bead_color), params: updated_attributes, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the bead color" do
        bead_color.reload
        expect(bead_color.name).to eq("Updated Color")
      end

      it "returns the updated bead color" do
        expect(json_response[:data][:name]).to eq("Updated Color")
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead color updated successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_color: { name: nil } } }

      before do
        patch api_v1_catalog_bead_color_path(bead_color), params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the bead color" do
        bead_color.reload
        expect(bead_color.name).to eq("Original Color")
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead color does not exist" do
      before do
        patch api_v1_catalog_bead_color_path(id: 999), params: { bead_color: { name: "Updated Color" } }, headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead color not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "DELETE /destroy" do
    context "when the bead color exists" do
      let!(:bead_color) { create(:bead_color) }

      it "returns http success" do
        delete api_v1_catalog_bead_color_path(bead_color), headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it "deletes the bead color" do
        # Ensure the color exists before deletion
        expect(Catalog::BeadColor.exists?(bead_color.id)).to be true

        delete api_v1_catalog_bead_color_path(bead_color), headers: valid_headers

        # Verify it's deleted after the request
        expect(Catalog::BeadColor.exists?(bead_color.id)).to be false
      end

      it "returns a success message" do
        delete api_v1_catalog_bead_color_path(bead_color), headers: valid_headers
        expect(json_response[:message]).to eq("Bead color deleted successfully")
      end

      it "returns success status in the response" do
        delete api_v1_catalog_bead_color_path(bead_color), headers: valid_headers
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead color does not exist" do
      before do
        delete api_v1_catalog_bead_color_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead color not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead color has associated records" do
      it "deletes the bead color and associated links" do
        # Create the color, bead, and link
        color = create(:bead_color)
        bead = create(:bead)
        link = create(:bead_color_link, bead: bead, color: color)

        color_id = color.id
        link_id = link.id
        bead_id = bead.id

        # Ensure both records exist before deletion
        expect(Catalog::BeadColor.exists?(color_id)).to be true
        expect(Catalog::BeadColorLink.exists?(link_id)).to be true

        delete api_v1_catalog_bead_color_path(color), headers: valid_headers

        # Verify the color and link are deleted, but the bead remains
        expect(Catalog::BeadColor.exists?(color_id)).to be false
        expect(Catalog::BeadColorLink.exists?(link_id)).to be false
        expect(Catalog::Bead.exists?(bead_id)).to be true
      end
    end
  end
end
