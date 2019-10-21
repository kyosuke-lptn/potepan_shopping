require 'rails_helper'

describe 'order機能', type: :system do
  let!(:product) do
    create(:product, name: "pretty shirt", variants: [variant], tax_category: tax_category)
  end
  let(:variant) { create(:variant) }
  let!(:new_product) do
    create(:product,
           name: "original shirt",
           available_on: Time.current,
           variants: [new_variant],
           tax_category: tax_category)
  end
  let(:new_variant) { create(:variant) }
  let(:tax_category) { create(:tax_category, is_default: true) }
  let!(:tax_rate) do
    create(:tax_rate,
           amount: 0.1,
           tax_categories: [tax_category],
           included_in_price: true,
           zone: zone)
  end
  let(:zone) { create(:zone, countries: [country]) }
  let(:store) { create(:store, cart_tax_country_iso: cart_tax_country_iso) }
  let(:cart_tax_country_iso) { country.iso }
  let(:country) { create(:country, iso: "JP") }

  before do
    allow_any_instance_of(Potepan::CheckoutController).to receive_messages(current_store: store)
  end

  it "カートに追加から購入までの流れ", js: true do
    visit potepan_product_path(product)

    aggregate_failures do
      expect(page).to have_content product.name.upcase
      select variant.options_text, from: "variant_id"
      quantity = 5
      select quantity, from: "quantity"
      click_button "カートへ入れる"

      product_total = Spree::Money.parse(product.price * quantity)
      single_price = Spree::Money.parse(product.price / (1 + tax_rate.amount))
      subcount = Spree::Money.parse(product_total.to_d / (1 + tax_rate.amount))
      tax_total = Spree::Money.parse(product_total.to_d - subcount.to_d)
      expect(page).to have_content single_price
      expect(find('.line_item_quantity').value).to eq quantity.to_s
      expect(page).to have_content product_total
      expect(page).to have_content tax_total
      expect(page).to have_content subcount
      expect(page).to have_button "購入する"
      within "tr.lineitem" do
        click_link product.name
      end

      add_quantity = 2
      select add_quantity, from: "quantity"
      click_button "カートへ入れる"

      all_quantity = (quantity + add_quantity).to_s
      expect(find('.line_item_quantity').value).to eq all_quantity
      # homeページへ移動
      find("a.navbar-brand").click

      find('#topbar-shoppting-cart').hover
      expect(page).to have_content product.name.upcase
      # expect(page).to have_content product.price
      expect(page).to have_button "Shopping Cart"
      expect(page).to have_button "Checkout"
      click_link new_product.name

      click_button "カートへ入れる"

      single_price = Spree::Money.parse(new_product.price / (1 + tax_rate.amount))
      order_total = (product.price * all_quantity.to_i) + new_product.price
      expect(page).to have_content new_product.name.upcase
      expect(page).to have_content single_price
      expect(all('.line_item_quantity')[1].value).to eq 1.to_s
      expect(page).to have_content Spree::Money.parse(order_total)
      change_quantity = 2
      all('.line_item_quantity')[1].set(change_quantity.to_s)
      click_button "アップデート"

      expect(all('.line_item_quantity')[1].value).to eq change_quantity.to_s

      first('.lineitem a.close').click
      first('.lineitem a.close').click

      expect(page).not_to have_content new_product.name
      expect(page).not_to have_content product.name
      expect(page).to have_content "カートに追加された商品はありません。"
      expect(page).to have_link "買い物を続ける"
    end
  end
end
