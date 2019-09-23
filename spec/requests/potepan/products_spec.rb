require 'rails_helper'

RSpec.describe "Potepan::Products", type: :request do
  describe "GET /potepan/products/:id" do
    context "商品が存在する時" do
      let(:taxon) { create(:taxon) }
      let!(:product) { create(:product, taxons: [taxon]) }
      let!(:product_with_taxon) { create(:product, taxons: [taxon]) }
      let!(:product_without_taxon) { create(:product) }

      context "関連商品が存在する時" do
        it "正常に応答する" do
          get potepan_product_path(product)
          expect(response).to be_successful
        end

        it "商品名が表示される" do
          get potepan_product_path(product)
          expect(response.body).to include product.name
        end

        it "関連した商品のみ表示される" do
          get potepan_product_path(product)
          aggregate_failures do
            expect(response.body).to include product_with_taxon.name
            expect(response.body).not_to include product_without_taxon.name
          end
        end

        it "「一覧ページへ戻る」へのリンクがある" do
          get potepan_product_path(product)
          expect(response.body).to include potepan_category_path(taxon.id)
        end
      end

      context "関連商品が存在しない時" do
        it "正常に応答する" do
          get potepan_product_path(product_without_taxon)
          expect(response).to be_successful
        end

        it "関連商品は表示されない" do
          get potepan_product_path(product_without_taxon)
          expect(response.body).not_to include product_with_taxon.name
        end

        it "「一覧ページへ戻る」へのリンクがない" do
          get potepan_product_path(product_without_taxon)
          expect(response.body).not_to include potepan_category_path(taxon.id)
        end
      end
    end

    context "商品が存在しない時" do
      it "エラーが発生する(ActiveRecord::RecordNotFound)" do
        expect do
          get potepan_product_path 1
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
