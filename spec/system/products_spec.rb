require 'rails_helper'

describe 'Products機能', type: :system do
  let!(:product) { create(:product, name: "sample2") }
  let!(:product2) { create(:product, name: "sample1") }
  let!(:taxonomy) { create(:taxonomy) }
  let!(:root_taxon) { taxonomy.root }
  let!(:parent_taxon) { create(:taxon,
                         name: 'Parent',
                         taxonomy_id: taxonomy.id,
                         parent: root_taxon) }
  let!(:child_taxon) { create(:taxon,
                        name: 'Child 1',
                        taxonomy_id: taxonomy.id,
                        parent: parent_taxon) }
  let!(:image) { File.open(File.expand_path('../fixtures/thinking-cat.jpg', __dir__)) }
  let!(:product_image) { product.images.create!(attachment: image) }
  let!(:product_image2) { product.images.create!(attachment: image) }
  let!(:product_taxons) { [parent_taxon, child_taxon].each{ |t| product.taxons << t } }
  let!(:product_taxons2) { [parent_taxon, child_taxon].each{ |t| product2.taxons << t } }

  describe '詳細表示機能' do
    before do
      visit "potepan/products/#{product.slug}"
    end

    context '商品詳細情報の表示' do
      subject { page }

      it { is_expected.to have_title "Single Product - BIGBAG Store" }
      it { is_expected.to have_content product.name }
      it { is_expected.to have_content product.price }
      it { is_expected.to have_content product.description }
      it '商品の画像' do
        img = first(".item").find("img")
        expect(img[:itemprop]).to eq "image"
      end
      it '商品の小さい画像' do
        link = first(".thumb").find('a')
        expect(link[:href]).to eq product.images.first.attachment.url(:product)
      end
    end

    context '関連商品の表示' do
      it '関連商品へのリンク' do
        img = first(".productImage").find("img")
        expect(img[:alt]).to eq "products-img"
      end
    end
  end
end
