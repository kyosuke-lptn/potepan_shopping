require 'rails_helper'

RSpec.describe "Potepan::Categories", type: :request do
  describe "GET /potepan/taxon_id" do
    context "taxonが存在する時" do
      let(:taxon) { create(:taxon) }

      it "responds successfully with taxon_id" do
        get potepan_category_path(taxon.id)
        expect(response).to have_http_status(200)
      end

      it "taxon-nameが表示される" do
        get potepan_category_path(taxon.id)
        expect(response.body).to include taxon.name
      end

      it "doesn't respond successfully with taxon_permalink" do
        expect do
          get potepan_category_path(taxon)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "taxonが存在しない時" do
      it "raise an error(ActiveRecord::RecordNotFound)" do
        expect do
          get potepan_category_path 1
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
