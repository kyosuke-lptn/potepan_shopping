require 'rails_helper'

describe 'Products機能', type: :system do
  let(:image) { create(:image) }
  let(:variant) { create(:master_variant, images: [image]) }
  let(:taxon) { create(:taxon) }
  let!(:product) { create(:product, master: variant, taxons: [taxon]) }
  let!(:taxon_product) { create(:product, taxons: [taxon]) }

  it "商品に関するページの確認" do
    visit potepan_product_path(product)

    aggregate_failures do
      expect(page).to have_title "#{product.name} - BIGBAG Store"
      expect(page).to have_content product.name
      expect(page).to have_content display_price(product)
      expect(page).to have_content product.description
      img = first(".item").find("img")
      expect(img[:itemprop]).to eq "image"
      img = first(".thumb").find("img")
      expect(img[:alt]).to eq 'product-thumb-img'
      within '#taxon-product' do
        expect(page).to have_link taxon_product.name
        expect(page).to have_content display_price(taxon_product)
        expect(page).not_to have_content product.name
      end
    end
  end
end