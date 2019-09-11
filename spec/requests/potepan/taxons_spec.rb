require 'rails_helper'

RSpec.describe "Potepan::Taxons", type: :request do
  let(:taxon) { create(:taxon) }

  describe "GET /potepan/taxon_id" do
    it "responds seuccessfully with taxon_id" do
      get potepan_taxon_path(taxon.id)
      expect(response).to have_http_status(200)
    end
    it "doesn't respond seuccessfully with taxon_permalink" do
      expect do
        get potepan_taxon_path(taxon)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
