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
      expect(page).not_to have_content "只今、在庫がない状態です。ご注文は可能ですが、入荷次第の配送になります。"
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

    context '在庫の数が少ないまたは０の時' do
      let!(:product) { create(:product_in_stock) }
      let!(:no_stock_product) { create(:product) }
      let!(:no_boa_stock5_product) { create(:product_not_backorderable) }
      let!(:no_boa_stock20_product) { create(:product_not_backorderable) }
      let!(:no_boa_no_stock_product) { create(:product_not_backorderable) }

      before do
        # no_stock_product.master.stock_items.first.set_count_on_hand(0)
        no_boa_stock5_product.master.stock_items.first.set_count_on_hand(5)
        no_boa_stock20_product.master.stock_items.first.set_count_on_hand(20)
        no_boa_no_stock_product.master.stock_items.first.set_count_on_hand(0)
      end

      it "quantityの選択が制限されるまたは選択できない", js: true do
        visit potepan_product_path(product)

        aggregate_failures do
          # 在庫あり、backorderableがtrue
          expect(page).to have_select('quantity', options: [*'1'..'10'])
          expect(find('#backorderable', visible: false)).not_to be_visible
          expect(find('#cantAddCart', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).to be_visible
          visit potepan_product_path(no_stock_product)
          # 在庫なし、backorderableがtrue
          expect(page).to have_select('quantity', options: [*'1'..'10'])
          expect(find('#backorderable', visible: false)).to be_visible
          expect(find('#cantAddCart', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).to be_visible
          visit potepan_product_path(no_boa_stock5_product)
          # 在庫5ある、backorderableがfalse
          expect(page).to have_select('quantity', options: [*'1'..'5'])
          expect(find('#backorderable', visible: false)).not_to be_visible
          expect(find('#cantAddCart', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).to be_visible
          visit potepan_product_path(no_boa_stock20_product)
          # 在庫20ある、backorderableがfalse
          expect(page).to have_select('quantity', options: [*'1'..'10'])
          expect(find('#backorderable', visible: false)).not_to be_visible
          expect(find('#cantAddCart', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).to be_visible
          visit potepan_product_path(no_boa_no_stock_product)
          # 在庫なし、backorderableがfalse
          expect(find('#backorderable', visible: false)).not_to be_visible
          expect(find('#cantAddCart', visible: false)).to be_visible
          expect(find('#quantity-selectbox', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).not_to be_visible
        end
      end
    end
  end

  context 'variantが複数の場合' do
    let(:variants) { create_list(:variant, 5) }
    let!(:product) { create(:product, master: variant, variants: variants, taxons: [taxon]) }

    it "variant_idを選択するselectboxができる" do
      visit potepan_product_path(product)

      expect(page).to have_select('variant_id', options: variants.map(&:options_text))
    end

    context '在庫の数が少ないまたは０の時' do
      let!(:product_whit_stock) do
        create(:product,
               variants: [
                 variant,
                 no_stock_item,
                 no_boa_stock_item5,
                 no_boa_stock_item20,
                 no_boa_no_stock_item,
               ])
      end
      let(:variant) { create(:variant) }
      let(:no_stock_item) { create(:variant) }
      let(:no_boa_stock_item5) { create(:variant) }
      let(:no_boa_stock_item20) { create(:variant) }
      let(:no_boa_no_stock_item) { create(:variant) }

      before do
        variant.stock_items.first.set_count_on_hand(13)
        no_stock_item.stock_items.first.set_count_on_hand(0)
        no_boa_stock_item5.stock_items.first.set_count_on_hand(5)
        no_boa_stock_item5.stock_items.first.update_column(:backorderable, false)
        no_boa_stock_item20.stock_items.first.set_count_on_hand(20)
        no_boa_stock_item20.stock_items.first.update_column(:backorderable, false)
        no_boa_no_stock_item.stock_items.first.set_count_on_hand(0)
        no_boa_no_stock_item.stock_items.first.update_column(:backorderable, false)
      end

      it "quantityの選択が制限されるまたは選択できない", js: true do
        visit potepan_product_path(product_whit_stock)

        aggregate_failures do
          # 在庫あり、backorderableがtrue
          expect(page).to have_select('quantity', options: [*'1'..'10'])
          expect(find('#backorderable', visible: false)).not_to be_visible
          expect(find('#cantAddCart', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).to be_visible
          within "#variant_id" do
            find("option[value='#{no_stock_item.id}']").click
          end
          # 在庫なし、backorderableがtrue
          expect(page).to have_select('quantity', options: [*'1'..'10'])
          expect(find('#backorderable', visible: false)).to be_visible
          expect(find('#cantAddCart', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).to be_visible
          within "#variant_id" do
            find("option[value='#{no_boa_stock_item5.id}']").click
          end
          # 在庫5ある、backorderableがfalse
          expect(page).to have_select('quantity', options: [*'1'..'5'])
          expect(find('#backorderable', visible: false)).not_to be_visible
          expect(find('#cantAddCart', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).to be_visible
          within "#variant_id" do
            find("option[value='#{no_boa_stock_item20.id}']").click
          end
          # 在庫20ある、backorderableがfalse
          expect(page).to have_select('quantity', options: [*'1'..'10'])
          expect(find('#backorderable', visible: false)).not_to be_visible
          expect(find('#cantAddCart', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).to be_visible
          within "#variant_id" do
            find("option[value='#{no_boa_no_stock_item.id}']").click
          end
          # 在庫なし、backorderableがfalse
          expect(find('#backorderable', visible: false)).not_to be_visible
          expect(find('#cantAddCart', visible: false)).to be_visible
          expect(find('#quantity-selectbox', visible: false)).not_to be_visible
          expect(find('#btn-to-add-product', visible: false)).not_to be_visible
        end
      end
    end
  end
end
