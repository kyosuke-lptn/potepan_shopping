require 'rails_helper'

RSpec.describe "Potepan::Taxons", type: :request do
  let(:taxon) { create(:taxon) }

  describe "GET /potepan/taxon_permalink*" do
    it "responds seuccessfully" do
      get potepan_taxons_path(taxon.to_param)
      expect(response).to have_http_status(200)
    end
  end
end
