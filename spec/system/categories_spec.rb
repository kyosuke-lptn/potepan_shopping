require 'rails_helper'

describe 'Categories機能', type: :system do
  let!(:product) { create(:product, taxons: [taxon_child]) }
  let(:taxonomy) { create(:taxonomy, name: 'Categories') }
  let(:taxon) { create(:taxon, parent_id: taxonomy.root.id, taxonomy: taxonomy) }
  let(:taxon_child) { create(:taxon, parent_id: taxon.id, taxonomy: taxonomy) }

  it "カテゴリー関連ページの確認" do
    visit potepan_category_path(taxon_child.id)

    aggregate_failures do
      expect(page).to have_title "#{taxon.name} - BIGBAG Store"
      within '#categories' do
        expect(page).to have_content taxon.root.name
        expect(page).to have_content taxon.name
        expect(page).to have_link taxon_child.name
        expect(page).to have_css '#category-parent'
        expect(page).to have_css '#category-child'
        expect(page).to have_css '.grandchild'
      end
      expect(page).to have_link product.name
      expect(page).to have_content display_price(product)
    end
  end

  context '色指定した場合' do
    let!(:value_color) do
      create(:option_value, name: "Red", presentation: "Red", option_type: type_color)
    end
    let!(:type_color) { create(:option_type, presentation: "Color") }
    let!(:red_product) { create(:product, variants: [red_variant]) }
    let(:red_variant) { create(:variant, option_values: [value_color]) }

    it "色指定した場合の表示確認" do
      visit potepan_category_path(taxon.id)
      click_link 'Red'

      aggregate_failures do
        expect(page).to have_content red_product.name
        expect(page).not_to have_content product.name
      end
    end
  end

  context 'ソート機能を使用した場合' do
    let(:old_product) { create(:product, available_on: 5.year.ago, taxons: [taxon_child]) }
    let(:new_product) { create(:product, available_on: 1.day.ago, taxons: [taxon_child]) }
    let(:expensive_product) { create(:product, price: 50.00, taxons: [taxon_child]) }
    let(:cheap_product) { create(:product, price: 1.00, taxons: [taxon_child]) }

    it "商品の表示確認", js: true do
      visit potepan_category_path(taxon_child.id)

      aggregate_failures do
        select '古い順', from: '並び順'
        within first('productBox') do
          expect(page).to have_content old_product.name
        end

        select '安い順', from: '並び順'
        within first('productBox') do
          expect(page).to have_content cheap_product.name
        end

        select '高い順', from: '並び順'
        within first('productBox') do
          expect(page).to have_content expensive_product.name
        end

        select '新着順', from: '並び順'
        within first('productBox') do
          expect(page).to have_content new_product.name
        end
      end
    end
  end
end
