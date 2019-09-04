require 'rails_helper'

RSpec.describe "Products", type: :request do
  let!(:product) { create(:product) }

  it "responds seuccessfully" do
    get potepan_product_path(product)
    aggregate_failures do
      expect(response).to be_successful
      expect(response).to have_http_status "200"
    end
  end
end
