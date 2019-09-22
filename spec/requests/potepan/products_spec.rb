require 'rails_helper'

RSpec.describe "Potepan::Products", type: :request do
  describe "GET /potepan/products/:id" do
    context "商品が存在する時" do
      let(:product) { create(:product) }
      let(:taxon) { create(:taxon) }

      context "関連商品が存在する時" do
        before do
          product.taxons << taxon
        end

        it "正常に応答する" do
          get potepan_product_path(product)
          expect(response).to be_successful
        end

        it "商品名が表示される" do
          get potepan_product_path(product)
          expect(response.body).to include product.name
        end

        it "関連商品へのリンクがある" do
          get potepan_product_path(product)
          expect(response.body).to include potepan_category_path(taxon.id)
        end
      end

      context "関連商品が存在しない時" do
        before do
          product.taxons = []
        end

        it "正常に応答する" do
          get potepan_product_path(product)
          expect(response).to be_successful
        end

        it "関連商品は表示されない" do
          get potepan_product_path(product)
          expect(response.body).not_to include taxon.name
        end

        it "関連商品へのリンクがない" do
          get potepan_product_path(product)
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
