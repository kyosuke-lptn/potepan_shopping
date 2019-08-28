require 'rails_helper'

describe 'Products機能', type: :system do
  let!(:product) { create(:product_show, :with_taxons_and_images, name: 'sample1') }
  let!(:product2) { create(:product_show, :with_taxons_and_images, name: 'sample2') }

  describe '詳細表示機能' do
    before do
      visit "potepan/products/#{product.slug}"
    end

    context '商品詳細情報の表示' do
      subject { page }

      it { is_expected.to have_title "#{product.name} - BIGBAG Store" }
      it { is_expected.to have_content product.name }
      it { is_expected.to have_content product.price }
      it { is_expected.to have_content product.description }
      it '商品の画像' do
        img = first(".item").find("img")
        expect(img[:itemprop]).to eq "image"
      end
      it '商品の小さい画像' do
        img = first(".thumb").find("img")
        expect(img[:alt]).to eq 'product-thumb-img'
      end
      it '関連商品へのリンク' do
        img = first(".productImage").find("img")
        expect(img[:alt]).to eq "products-img"
      end
    end
  end
end
