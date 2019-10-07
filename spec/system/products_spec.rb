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

  context 'variantがmasterのみの場合' do
    it "variant_idの選択が隠れて埋め込まれている" do
      visit potepan_product_path(product)

      expect(find('#variant_id', visible: false).value).to eq variant.id.to_s
    end
  end

  context 'variantが複数の場合' do
    let(:variants) { create_list(:variant, 5) }
    let!(:product) { create(:product, master: variant, variants: variants, taxons: [taxon]) }

    it "variant_idを選択するselectboxができる" do
      visit potepan_product_path(product)

      expect(page).to have_select('variant_id', options: variants.map(&:options_text))
    end
  end
end
