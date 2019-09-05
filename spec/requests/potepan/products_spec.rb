require 'rails_helper'

RSpec.describe "Potepan::Products", type: :request do
  let!(:product) { create(:product) }

  describe "GET /potepan/products/:id" do
    it "responds seuccessfully" do
      get potepan_product_path(product)
      expect(response).to be_successful
    end
  end
end
