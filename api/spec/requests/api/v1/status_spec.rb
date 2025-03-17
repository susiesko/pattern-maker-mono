require 'rails_helper'

RSpec.describe "Api::V1::Status", type: :request do
  describe "GET /api/v1/status" do
    it "returns status information" do
      get "/api/v1/status"
      
      expect(response).to have_http_status(:success)
      
      json_response = JSON.parse(response.body)
      expect(json_response["success"]).to be true
      expect(json_response["api_version"]).to eq("v1")
      expect(json_response["status"]).to eq("online")
      expect(json_response).to have_key("timestamp")
    end
  end
end