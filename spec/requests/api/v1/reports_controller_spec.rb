require "rails_helper"

RSpec.describe "Reports", type: :request do
  describe "GET /reports/disbursement_summary" do
    it "returns JSON with disbursement data" do
      create(:merchant) # at least one merchant
      get "/api/v1/reports/disbursement_summary.json"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end

    it "returns CSV with disbursement data" do
      create(:merchant)
      get "/api/v1/reports/disbursement_summary.csv"

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("text/csv")
      expect(response.body).to include("Year")
    end
  end
end
