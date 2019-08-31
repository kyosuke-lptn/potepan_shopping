require 'rails_helper'

describe 'Products機能', type: :system do
  let!(:image) { create(:image) }
  let!(:varient) { create(:master_variant, images: [image]) }
  let(:product) { varient.product }

  describe '詳細表示機能' do
    before do
      visit product_path(product)
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
    end
  end
end
