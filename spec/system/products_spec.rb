require 'rails_helper'

describe 'Products機能', type: :system do
  let!(:image) { create(:image) }
  let!(:variant) { create(:master_variant, images: [image]) }
  let(:product) { variant.product }
  let!(:taxonomy) { create(:taxonomy, name: 'Categories') }
  let(:taxon) { create(:taxon, parent_id: taxonomy.root.id, taxonomy: taxonomy) }

  before do
    product.taxons << taxon
  end

  it "商品に関するページの確認" do
    visit potepan_category_path(taxon.id)

    aggregate_failures do
      expect(page).to have_title "#{taxon.name} - BIGBAG Store"
      within '#categories' do
        expect(page).to have_content taxon.products.first.name
        expect(page).to have_content taxon.name
        expect(page).to have_link taxon.name
      end
      expect(page).to have_content product.name
      expect(page).to have_content product.display_price
    end

    within '#categories' do
      click_link product.name
    end

    aggregate_failures do
      expect(page).to have_title "#{product.name} - BIGBAG Store"
      expect(page).to have_content product.name
      expect(page).to have_content product.display_price
      expect(page).to have_content product.description
      img = first(".item").find("img")
      expect(img[:itemprop]).to eq "image"
      img = first(".thumb").find("img")
      expect(img[:alt]).to eq 'product-thumb-img'
    end
  end
end
