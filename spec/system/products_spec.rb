require 'rails_helper'

describe 'Products機能', type: :system do
  let!(:image) { create(:image) }
  let!(:variant) { create(:master_variant, images: [image]) }
  let(:product) { variant.product }
  let(:taxon_product) { create(:product) }
  let(:taxon) { create(:taxonomy, name: 'Categories').root }

  before do
    product.taxons << taxon
    taxon_product.taxons << taxon
  end

  it "商品に関するページの確認" do
    visit potepan_product_path(product)

    aggregate_failures do
      expect(page).to have_title "#{product.name} - BIGBAG Store"
      expect(page).to have_content product.name
      expect(page).to have_content product.display_price
      expect(page).to have_content product.description
      img = first(".item").find("img")
      expect(img[:itemprop]).to eq "image"
      img = first(".thumb").find("img")
      expect(img[:alt]).to eq 'product-thumb-img'
      expect(page).to have_link taxon_product.name
      expect(page).to have_content taxon_product.display_price
    end
  end
end
