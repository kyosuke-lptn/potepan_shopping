require 'rails_helper'

RSpec.describe "Potepan::Products", type: :request do
  describe "GET /potepan/products/:id" do
    context "商品が存在する時" do
      let!(:product) { create(:product) }

      it "正常に応答する" do
        get potepan_product_path(product)
        expect(response).to be_successful
      end

      it "商品名が表示される" do
        get potepan_product_path(product)
        expect(response.body).to include product.name
      end
    end

    context "商品が存在しない時" do
      it "raise an error(ActiveRecord::RecordNotFound)" do
        expect do
          get potepan_product_path 1
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
