# frozen_string_literal: true

# rubocop:disable RSpec/MultipleExpectations

require 'rails_helper'

RSpec.describe "Api::V1::Catalog::BeadFinishes", type: :request do
  let(:valid_headers) { { "ACCEPT" => "application/json" } }
  let(:json_response) { JSON.parse(response.body, symbolize_names: true) }

  describe "GET /index" do
    context "when there are no bead finishes" do
      before do
        get api_v1_catalog_bead_finishes_path, headers: valid_headers
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

    context "when there are bead finishes" do
      let(:finishes) do
        [
          create(:bead_finish, name: "Finish 1"),
          create(:bead_finish, name: "Finish 2"),
          create(:bead_finish, name: "Finish 3")
        ]
      end

      before do
        finishes # Reference to ensure creation before the request
        get api_v1_catalog_bead_finishes_path, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns all bead finishes" do
        expect(json_response[:data].size).to eq(3)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end
  end

  describe "GET /show" do
    context "when the bead finish exists" do
      let(:bead_finish) { create(:bead_finish) }
      let(:bead) { create(:bead, :with_finishes, finishes_count: 0) } # Create bead without finishes

      before do
        # Manually create the association between bead and finish
        create(:bead_finish_link, bead: bead, finish: bead_finish)
        get api_v1_catalog_bead_finish_path(bead_finish), headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns the requested bead finish" do
        expect(json_response[:data][:id]).to eq(bead_finish.id)
        expect(json_response[:data][:name]).to eq(bead_finish.name)
      end

      it "includes associated beads" do
        expect(json_response[:data][:beads]).to be_present
        expect(json_response[:data][:beads].first[:id]).to eq(bead.id)
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead finish does not exist" do
      before do
        get api_v1_catalog_bead_finish_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead finish not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { bead_finish: { name: "New Finish" } } }

      before do
        post api_v1_catalog_bead_finishes_path, params: valid_attributes, headers: valid_headers
      end

      it "returns http created" do
        expect(response).to have_http_status(:created)
      end

      it "creates a new bead finish" do
        expect(Catalog::BeadFinish.count).to eq(1)
        expect(Catalog::BeadFinish.first.name).to eq("New Finish")
      end

      it "returns the created bead finish" do
        expect(json_response[:data][:name]).to eq("New Finish")
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead finish created successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_finish: { name: nil } } }

      before do
        post api_v1_catalog_bead_finishes_path, params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create a new bead finish" do
        expect(Catalog::BeadFinish.count).to eq(0)
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
    let(:bead_finish) { create(:bead_finish, name: "Original Finish") }

    context "with valid parameters" do
      let(:updated_attributes) { { bead_finish: { name: "Updated Finish" } } }

      before do
        patch api_v1_catalog_bead_finish_path(bead_finish), params: updated_attributes, headers: valid_headers
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "updates the bead finish" do
        bead_finish.reload
        expect(bead_finish.name).to eq("Updated Finish")
      end

      it "returns the updated bead finish" do
        expect(json_response[:data][:name]).to eq("Updated Finish")
      end

      it "returns a success message" do
        expect(json_response[:message]).to eq("Bead finish updated successfully")
      end

      it "returns success status in the response" do
        expect(json_response[:success]).to be true
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { bead_finish: { name: nil } } }

      before do
        patch api_v1_catalog_bead_finish_path(bead_finish), params: invalid_attributes, headers: valid_headers
      end

      it "returns http unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the bead finish" do
        bead_finish.reload
        expect(bead_finish.name).to eq("Original Finish")
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Name can't be blank")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead finish does not exist" do
      before do
        patch api_v1_catalog_bead_finish_path(id: 999), params: { bead_finish: { name: "Updated Finish" } }, headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead finish not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end
  end

  describe "DELETE /destroy" do
    context "when the bead finish exists" do
      let(:bead_finish) { create(:bead_finish) }

      it "returns http success" do
        delete api_v1_catalog_bead_finish_path(bead_finish), headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it "deletes the bead finish" do
        finish = create(:bead_finish) # Create a separate finish for this test
        finish_id = finish.id

        # Ensure the finish exists before deletion
        expect(Catalog::BeadFinish.exists?(finish_id)).to be true

        delete api_v1_catalog_bead_finish_path(finish), headers: valid_headers

        # Verify it's deleted after the request
        expect(Catalog::BeadFinish.exists?(finish_id)).to be false
      end

      it "returns a success message" do
        delete api_v1_catalog_bead_finish_path(bead_finish), headers: valid_headers
        expect(json_response[:message]).to eq("Bead finish deleted successfully")
      end

      it "returns success status in the response" do
        delete api_v1_catalog_bead_finish_path(bead_finish), headers: valid_headers
        expect(json_response[:success]).to be true
      end
    end

    context "when the bead finish does not exist" do
      before do
        delete api_v1_catalog_bead_finish_path(id: 999), headers: valid_headers
      end

      it "returns http not found" do
        expect(response).to have_http_status(:not_found)
      end

      it "returns an error message" do
        expect(json_response[:errors]).to include("Bead finish not found")
      end

      it "returns failure status in the response" do
        expect(json_response[:success]).to be false
      end
    end

    context "when the bead finish has associated records" do
      it "deletes the bead finish and associated links" do
        # Create the finish and bead
        finish = create(:bead_finish)
        bead = create(:bead)

        # Create the association
        link = create(:bead_finish_link, bead: bead, finish: finish)

        finish_id = finish.id
        link_id = link.id
        bead_id = bead.id

        # Ensure both records exist before deletion
        expect(Catalog::BeadFinish.exists?(finish_id)).to be true
        expect(Catalog::BeadFinishLink.exists?(link_id)).to be true

        delete api_v1_catalog_bead_finish_path(finish), headers: valid_headers

        # Verify the finish and link are deleted, but the bead remains
        expect(Catalog::BeadFinish.exists?(finish_id)).to be false
        expect(Catalog::BeadFinishLink.exists?(link_id)).to be false
        expect(Catalog::Bead.exists?(bead_id)).to be true
      end
    end
  end
end
