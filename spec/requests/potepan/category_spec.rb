require 'rails_helper'

RSpec.describe "Potepan::Categories", type: :request do
  describe "GET /potepan/taxon_id" do
    context "URLで指定したカテゴリーが存在する時" do
      let!(:taxonomy) { create(:taxonomy, name: 'Categories') }
      let(:taxon) { create(:taxon, parent_id: taxonomy.root.id, taxonomy: taxonomy) }

      context "params[:id]がtaxon_idの時" do
        it "正常に応答する" do
          get potepan_category_path(taxon.id)
          expect(response).to have_http_status(200)
        end

        it "カテゴリー名が表示される" do
          get potepan_category_path(taxon.id)
          expect(response.body).to include taxon.name
        end
      end

      context "params[:id]がtaxon_permalinkの時" do
        it "正常に応答せず、エラーが発生する(ActiveRecord::RecordNotFound)" do
          expect do
            get potepan_category_path(taxon)
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "URLで指定したカテゴリーが存在しない時" do
      it "正常に応答せず、エラーが発生する(ActiveRecord::RecordNotFound)" do
        expect do
          get potepan_category_path 1
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
