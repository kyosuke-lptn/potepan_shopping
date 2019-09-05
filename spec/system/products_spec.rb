require 'rails_helper'

describe 'Products機能', type: :system do
  let!(:image) { create(:image) }
  let!(:variant) { create(:master_variant, images: [image]) }
  let(:product) { variant.product }
  let(:taxon) { create(:taxon) }
  let(:taxon_child) { create(:taxon, parent_id: taxon.id, taxonomy: taxon.taxonomy) }

  before do
    product.taxons << taxon
    product.taxons << taxon_child
  end

  it "商品に関するページの確認" do
    visit potepan_taxons_path(taxon)

    aggregate_failures do
      expect(page).to have_title "#{taxon.name} - BIGBAG Store"
      expect(page).to have_content product.name
      expect(page).to have_content product.price
      expect(page).to have_content taxon.name
      expect(page).to have_link taxon.name
    end

    click_link product.name

    aggregate_failures do
      expect(page).to have_title "#{product.name} - BIGBAG Store"
      expect(page).to have_content product.name
      expect(page).to have_content product.price
      expect(page).to have_content product.description
      img = first(".item").find("img")
      expect(img[:itemprop]).to eq "image"
      img = first(".thumb").find("img")
      expect(img[:alt]).to eq 'product-thumb-img'
    end
  end
end
