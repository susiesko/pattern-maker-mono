# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Catalog::Beads", type: :request do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  describe "GET /index" do
    context "when there are no beads" do
      before do
        get api_v1_catalog_beads_path, headers: valid_headers
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

    context "when there are beads" do
      let(:beads) { create_list(:bead, 3) }

      before do
        get api_v1_catalog_beads_path, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns all beads" do
        expect(json_response[:data].size).to eq(3)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end

      it "includes brand, size, colors, and finishes in the response" do
        expect(json_response[:data].first).to include(:brand, :size, :colors, :finishes)
      end
    end

    context "with filtering" do
      let(:brand1) { create(:bead_brand) }
      let(:brand2) { create(:bead_brand) }
      let(:size1) { create(:bead_size, brand: brand1) }
      let(:size2) { create(:bead_size, brand: brand2) }
      let(:bead1) { create(:bead, brand: brand1, size: size1) }
      let(:bead2) { create(:bead, brand: brand2, size: size2) }
      let(:color) { create(:bead_color) }
      let(:finish) { create(:bead_finish) }

      before do
        create(:bead_color_link, bead: bead1, color: color)
        create(:bead_finish_link, bead: bead2, finish: finish)
      end

      it "filters by brand_id" do
        get api_v1_catalog_beads_path, params: { brand_id: brand1.id }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(bead1.id)
      end

      it "filters by size_id" do
        get api_v1_catalog_beads_path, params: { size_id: size2.id }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(bead2.id)
      end

      it "filters by color_id" do
        get api_v1_catalog_beads_path, params: { color_id: color.id }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(bead1.id)
      end

      it "filters by finish_id" do
        get api_v1_catalog_beads_path, params: { finish_id: finish.id }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(bead2.id)
      end

      it "filters by search term matching name" do
        get api_v1_catalog_beads_path, params: { search: bead1.name }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(bead1.id)
      end

      it "filters by search term matching brand_product_code" do
        get api_v1_catalog_beads_path, params: { search: bead2.brand_product_code }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(bead2.id)
      end
    end
  end

  describe "GET /show" do
    context "when the bead exists" do
      let(:bead) { create(:bead) }
      let(:color) { create(:bead_color) }
      let(:finish) { create(:bead_finish) }

      before do
        create(:bead_color_link, bead: bead, color: color)
        create(:bead_finish_link, bead: bead, finish: finish)
        get api_v1_catalog_bead_path(bead), headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the requested bead" do
        expect(json_response[:data][:id]).to eq(bead.id)
        expect(json_response[:data][:name]).to eq(bead.name)
      end

      it "includes brand in the response" do
        expect(json_response[:data][:brand][:id]).to eq(bead.brand.id)
      end

      it "includes size in the response" do
        expect(json_response[:data][:size][:id]).to eq(bead.size.id)
      end

      it "includes colors in the response" do
        expect(json_response[:data][:colors].first[:id]).to eq(color.id)
      end

      it "includes finishes in the response" do
        expect(json_response[:data][:finishes].first[:id]).to eq(finish.id)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead does not exist" do
      before do
        get api_v1_catalog_bead_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "POST /create" do
    let(:brand) { create(:bead_brand) }
    let(:size) { create(:bead_size) }
    let(:colors) { create_list(:bead_color, 2) }
    let(:finishes) { create_list(:bead_finish, 2) }

    context "with valid parameters" do
      let(:valid_attributes) do
        {
          bead: {
            name: "New Bead",
            brand_product_code: "NB-001",
            brand_id: brand.id,
            size_id: size.id,
            metadata: { material: "glass" },
            color_ids: colors.map(&:id),
            finish_ids: finishes.map(&:id)
          }
        }
      end

      before do
        post api_v1_catalog_beads_path, params: valid_attributes, headers: valid_headers
      end

      it "returns http created" do
        expect(response).to have_http_status(:created)
      end

      it "creates a new bead" do
        expect(Catalog::Bead.count).to eq(1)
        expect(Catalog::Bead.first.name).to eq("New Bead")
      end

      it "associates the bead with the specified colors" do
        expect(Catalog::Bead.first.colors.count).to eq(2)
        expect(Catalog::Bead.first.colors.map(&:id)).to match_array(colors.map(&:id))
      end

      it "associates the bead with the specified finishes" do
        expect(Catalog::Bead.first.finishes.count).to eq(2)
        expect(Catalog::Bead.first.finishes.map(&:id)).to match_array(finishes.map(&:id))
      end

      it "returns the created bead" do
        expect(json_response[:data][:name]).to eq("New Bead")
        expect(json_response[:data][:brand_product_code]).to eq("NB-001")
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead created successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          bead: {
            name: nil,
            brand_product_code: "NB-001",
            brand_id: brand.id,
            size_id: size.id
          }
        }
      end

      before do
        post api_v1_catalog_beads_path, params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new bead" do
        expect(Catalog::Bead.count).to eq(0)
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
    let(:bead) { create(:bead, name: "Original Name") }
    let(:new_color) { create(:bead_color) }
    let(:new_finish) { create(:bead_finish) }

    context "with valid parameters" do
      let(:updated_attributes) do
        {
          bead: {
            name: "Updated Name",
            color_ids: [ new_color.id ],
            finish_ids: [ new_finish.id ]
          }
        }
      end

      before do
        patch api_v1_catalog_bead_path(bead), params: updated_attributes, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the bead" do
        bead.reload
        expect(bead.name).to eq("Updated Name")
      end

      it "updates the bead's colors" do
        bead.reload
        expect(bead.colors.count).to eq(1)
        expect(bead.colors.first.id).to eq(new_color.id)
      end

      it "updates the bead's finishes" do
        bead.reload
        expect(bead.finishes.count).to eq(1)
        expect(bead.finishes.first.id).to eq(new_finish.id)
      end

      it "returns the updated bead" do
        expect(json_response[:data][:name]).to eq("Updated Name")
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead updated successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead: { name: nil } } }

      before do
        patch api_v1_catalog_bead_path(bead), params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the bead" do
        bead.reload
        expect(bead.name).to eq("Original Name")
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead does not exist" do
      before do
        patch api_v1_catalog_bead_path(id: 999), params: { bead: { name: "Updated Name" } }, headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "DELETE /destroy" do
    context "when the bead exists" do
      let(:bead) { create(:bead) }
      let(:color) { create(:bead_color) }
      let(:finish) { create(:bead_finish) }
      let(:color_link) { create(:bead_color_link, bead: bead, color: color) }
      let(:finish_link) { create(:bead_finish_link, bead: bead, finish: finish) }

      it "returns http success" do
        delete api_v1_catalog_bead_path(bead), headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it "deletes the bead" do
        expect {
          delete api_v1_catalog_bead_path(bead), headers: valid_headers
        }.to change(Catalog::Bead, :count).by(-1)
      end

      it "deletes associated color links" do
        expect {
          delete api_v1_catalog_bead_path(bead), headers: valid_headers
        }.to change(Catalog::BeadColorLink, :count).by(-1)
      end

      it "deletes associated finish links" do
        expect {
          delete api_v1_catalog_bead_path(bead), headers: valid_headers
        }.to change(Catalog::BeadFinishLink, :count).by(-1)
      end

      it "returns a success message" do
        delete api_v1_catalog_bead_path(bead), headers: valid_headers
        expect(json_response[:message]).to eq("Bead deleted successfully")
      end

      it "returns success status in the response" do
        delete api_v1_catalog_bead_path(bead), headers: valid_headers
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead does not exist" do
      before do
        delete api_v1_catalog_bead_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end
end
