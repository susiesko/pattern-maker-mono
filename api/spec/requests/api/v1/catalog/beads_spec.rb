# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations

require 'rails_helper'

# Shared contexts to reduce the number of let statements in each example group
RSpec.shared_context "with common request setup" do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }
end

# Helper method to create test data for filtering
def create_filter_test_data
  first_brand = create(:bead_brand)
  second_brand = create(:bead_brand)
  first_size = create(:bead_size, brand: first_brand)
  second_size = create(:bead_size, brand: second_brand)
  first_bead = create(:bead, brand: first_brand, size: first_size)
  second_bead = create(:bead, brand: second_brand, size: second_size)
  color = create(:bead_color)
  finish = create(:bead_finish)

  create(:bead_color_link, bead: first_bead, color: color)
  create(:bead_finish_link, bead: second_bead, finish: finish)

  {
    first_brand: first_brand,
    second_brand: second_brand,
    first_size: first_size,
    second_size: second_size,
    first_bead: first_bead,
    second_bead: second_bead,
    color: color,
    finish: finish
  }
end

# Helper method to create a bead with associated color and finish
def create_bead_with_associations
  bead = create(:bead)
  color = create(:bead_color)
  finish = create(:bead_finish)

  create(:bead_color_link, bead: bead, color: color)
  create(:bead_finish_link, bead: bead, finish: finish)

  {
    bead: bead,
    color: color,
    finish: finish
  }
end

# Helper method to create data for bead creation tests
def create_bead_creation_data
  brand = create(:bead_brand)
  size = create(:bead_size)
  colors = create_list(:bead_color, 2)
  finishes = create_list(:bead_finish, 2)

  {
    brand: brand,
    size: size,
    colors: colors,
    finishes: finishes,
    valid_attributes: {
      bead: {
        name: "New Bead",
        brand_product_code: "NB-001",
        brand_id: brand.id,
        size_id: size.id,
        metadata: { material: "glass" },
        color_ids: colors.map(&:id),
        finish_ids: finishes.map(&:id)
      }
    },
    invalid_attributes: {
      bead: {
        name: nil,
        brand_product_code: "NB-001",
        brand_id: brand.id,
        size_id: size.id
      }
    }
  }
end

# Helper method to create data for bead update tests
def create_bead_update_data
  bead = create(:bead, name: "Original Name")
  color = create(:bead_color)
  finish = create(:bead_finish)

  {
    bead: bead,
    color: color,
    finish: finish,
    valid_attributes: {
      bead: {
        name: "Updated Name",
        color_ids: [ color.id ],
        finish_ids: [ finish.id ]
      }
    },
    invalid_attributes: {
      bead: { name: nil }
    }
  }
end

# Helper method to create data for bead deletion tests
def create_bead_deletion_data
  bead = create(:bead)
  color = create(:bead_color)
  finish = create(:bead_finish)
  color_link = create(:bead_color_link, bead: bead, color: color)
  finish_link = create(:bead_finish_link, bead: bead, finish: finish)

  {
    bead: bead,
    color: color,
    finish: finish,
    color_link: color_link,
    finish_link: finish_link
  }
end

RSpec.describe "Api::V1::Catalog::Beads", type: :request do
  include_context "with common request setup"

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
      let(:index_beads) { create_list(:bead, 3) }

      before do
        index_beads # ensure beads are created
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
      # Use a single let statement with the helper method instead of multiple let statements
      let(:filter_data) { create_filter_test_data }

      it "filters by brand_id" do
        get api_v1_catalog_beads_path, params: { brand_id: filter_data[:first_brand].id }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(filter_data[:first_bead].id)
      end

      it "filters by size_id" do
        get api_v1_catalog_beads_path, params: { size_id: filter_data[:second_size].id }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(filter_data[:second_bead].id)
      end

      it "filters by color_id" do
        get api_v1_catalog_beads_path, params: { color_id: filter_data[:color].id }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(filter_data[:first_bead].id)
      end

      it "filters by finish_id" do
        get api_v1_catalog_beads_path, params: { finish_id: filter_data[:finish].id }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(filter_data[:second_bead].id)
      end

      it "filters by search term matching name" do
        get api_v1_catalog_beads_path, params: { search: filter_data[:first_bead].name }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(filter_data[:first_bead].id)
      end

      it "filters by search term matching brand_product_code" do
        get api_v1_catalog_beads_path, params: { search: filter_data[:second_bead].brand_product_code }, headers: valid_headers
        expect(json_response[:data].size).to eq(1)
        expect(json_response[:data].first[:id]).to eq(filter_data[:second_bead].id)
      end
    end
  end

  describe "GET /show" do
    context "when the bead exists" do
      # Use a single let statement with the helper method
      let(:show_data) { create_bead_with_associations }

      before do
        get api_v1_catalog_bead_path(show_data[:bead]), headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the requested bead" do
        expect(json_response[:data][:id]).to eq(show_data[:bead].id)
        expect(json_response[:data][:name]).to eq(show_data[:bead].name)
      end

      it "includes brand in the response" do
        expect(json_response[:data][:brand][:id]).to eq(show_data[:bead].brand.id)
      end

      it "includes size in the response" do
        expect(json_response[:data][:size][:id]).to eq(show_data[:bead].size.id)
      end

      it "includes colors in the response" do
        expect(json_response[:data][:colors].first[:id]).to eq(show_data[:color].id)
      end

      it "includes finishes in the response" do
        expect(json_response[:data][:finishes].first[:id]).to eq(show_data[:finish].id)
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
    # Use a single let statement with the helper method
    let(:create_data) { create_bead_creation_data }

    context "with valid parameters" do
      before do
        post api_v1_catalog_beads_path, params: create_data[:valid_attributes], headers: valid_headers
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
        expect(Catalog::Bead.first.colors.map(&:id)).to match_array(create_data[:colors].map(&:id))
      end

      it "associates the bead with the specified finishes" do
        expect(Catalog::Bead.first.finishes.count).to eq(2)
        expect(Catalog::Bead.first.finishes.map(&:id)).to match_array(create_data[:finishes].map(&:id))
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
      before do
        post api_v1_catalog_beads_path, params: create_data[:invalid_attributes], headers: valid_headers
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
    # Use a single let statement with the helper method
    let(:update_data) { create_bead_update_data }

    context "with valid parameters" do
      before do
        patch api_v1_catalog_bead_path(update_data[:bead]), params: update_data[:valid_attributes], headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the bead" do
        update_data[:bead].reload
        expect(update_data[:bead].name).to eq("Updated Name")
      end

      it "updates the bead's colors" do
        update_data[:bead].reload
        expect(update_data[:bead].colors.count).to eq(1)
        expect(update_data[:bead].colors.first.id).to eq(update_data[:color].id)
      end

      it "updates the bead's finishes" do
        update_data[:bead].reload
        expect(update_data[:bead].finishes.count).to eq(1)
        expect(update_data[:bead].finishes.first.id).to eq(update_data[:finish].id)
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
      before do
        patch api_v1_catalog_bead_path(update_data[:bead]), params: update_data[:invalid_attributes], headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the bead" do
        update_data[:bead].reload
        expect(update_data[:bead].name).to eq("Original Name")
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
      # Use a single let statement with the helper method
      let(:delete_data) { create_bead_deletion_data }

      it "returns http success" do
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it "deletes the bead" do
        bead_id = delete_data[:bead].id
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(Catalog::Bead.find_by(id: bead_id)).to be_nil
      end

      it "deletes associated color links" do
        color_link_id = delete_data[:color_link].id
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(Catalog::BeadColorLink.find_by(id: color_link_id)).to be_nil
      end

      it "deletes associated finish links" do
        finish_link_id = delete_data[:finish_link].id
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(Catalog::BeadFinishLink.find_by(id: finish_link_id)).to be_nil
      end

      it "returns a success message" do
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
        expect(json_response[:message]).to eq("Bead deleted successfully")
      end

      it "returns success status in the response" do
        delete api_v1_catalog_bead_path(delete_data[:bead]), headers: valid_headers
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
