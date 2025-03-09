require 'rails_helper'

RSpec.describe "Api::V1::Beads", type: :request do
  # Initialize test data
  let!(:brand) { create(:bead_brand, name: "Miyuki") }
  let!(:type) { create(:bead_type, name: "Delica", brand: brand) }
  let!(:size) { create(:bead_size, size: "11/0", brand: brand, type: type) }
  let!(:color) { create(:bead_color, name: "Red") }
  let!(:finish) { create(:bead_finish, name: "Matte") }
  let!(:beads) { create_list(:bead, 10, brand: brand, type: type, size: size) }
  let(:bead_id) { beads.first.id }

  # Test suite for GET /api/v1/beads
  describe "GET /api/v1/beads" do
    before { get '/api/v1/beads' }

    it "returns beads" do
      expect(json).not_to be_empty
      expect(json['beads'].size).to eq(10)
    end

    it "returns status code 200" do
      expect(response).to have_http_status(200)
    end

    it "includes pagination metadata" do
      expect(json['meta']).to include('current_page', 'total_count')
    end
  end

  # Test suite for GET /api/v1/beads/:id
  describe "GET /api/v1/beads/:id" do
    before { get "/api/v1/beads/#{bead_id}" }

    context "when the record exists" do
      it "returns the bead" do
        expect(json).not_to be_empty
        expect(json['id']).to eq(bead_id)
      end

      it "returns status code 200" do
        expect(response).to have_http_status(200)
      end
    end

    context "when the record does not exist" do
      let(:bead_id) { 100 }

      it "returns status code 404" do
        expect(response).to have_http_status(404)
      end

      it "returns a not found message" do
        expect(json['error']).to match(/Bead not found/)
      end
    end
  end

  # Test suite for filtering
  describe "filtering" do
    context "by brand" do
      before { get "/api/v1/beads?brand_id=#{brand.id}" }

      it "returns beads with the specified brand" do
        expect(json['beads']).not_to be_empty
        json['beads'].each do |bead|
          expect(bead['brand']['id']).to eq(brand.id)
        end
      end
    end

    # Add more filtering tests as needed
  end
end
