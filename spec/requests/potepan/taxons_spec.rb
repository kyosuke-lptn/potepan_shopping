require 'rails_helper'

RSpec.describe "Potepan::Taxons", type: :request do
  describe "GET /potepan/taxon_id" do
    context "taxonが存在する時" do
      let(:taxon) { create(:taxon) }

      it "responds successfully with taxon_id" do
        get potepan_taxon_path(taxon.id)
        expect(response).to have_http_status(200)
      end
      it "taxon-nameが表示される" do
        get potepan_taxon_path(taxon.id)
        expect(response.body).to include taxon.name
      end
      it "doesn't respond successfully with taxon_permalink" do
        expect do
          get potepan_taxon_path(taxon)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "taxonが存在しない時" do
      it "raise an error" do
        expect do
          get potepan_taxon_path 1
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
