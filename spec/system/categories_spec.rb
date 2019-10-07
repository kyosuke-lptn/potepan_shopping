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
        expect(page).to have_css '.category-parent'
        expect(page).to have_css '.category-child'
        expect(page).to have_css '.grandchild'
      end
      expect(page).to have_link product.name
      expect(page).to have_content display_price(product)
    end
  end

  context '色やサイズを指定した場合' do
    let!(:value_color) do
      create(:option_value, name: "Red", presentation: "Red", option_type: option_color)
    end
    let!(:option_color) { create(:option_type, presentation: "Color") }
    let!(:value_size) do
      create(:option_value, name: "Small", presentation: "S", option_type: option_size)
    end
    let!(:option_size) { create(:option_type, presentation: "Size") }
    let(:red_and_small_variant) do
      create(:variant, option_values: [value_color, value_size])
    end
    let!(:red_and_small_product) do
      create(:product, variants: [red_and_small_variant], taxons: [taxon_child])
    end
    let(:other_variant) do
      create(:variant, option_values: [value_color, value_size])
    end
    let!(:same_taxon_product) do
      create(:product, variants: [other_variant], taxons: [taxon])
    end

    it "色指定した場合の表示確認" do
      visit potepan_category_path(taxon_child.id)
      within find('a', text: 'Red') do
        expect(page).to have_selector 'span', text: "(1)"
      end
      click_link "Red"

      aggregate_failures do
        expect(page).to have_content red_and_small_product.name
        expect(page).not_to have_content product.name
        expect(page).not_to have_content same_taxon_product.name
      end
    end

    it "サイズ指定した場合の表示確認" do
      visit potepan_category_path(taxon_child.id)
      within ".list-unstyled.clearfix" do
        within find('a', text: 'S') do
          expect(page).to have_selector 'span', text: "(1)"
        end
        click_link "S"
      end

      aggregate_failures do
        expect(page).to have_content red_and_small_product.name
        expect(page).not_to have_content product.name
        expect(page).not_to have_content same_taxon_product.name
      end
    end
  end

  context 'ソート機能を使用した場合' do
    let!(:old_product) { create(:product, available_on: 5.year.ago, taxons: [taxon_child]) }
    let!(:new_product) { create(:product, available_on: 1.day.ago, taxons: [taxon_child]) }
    let!(:expensive_product) { create(:product, price: 50.00, taxons: [taxon_child]) }
    let!(:cheap_product) { create(:product, price: 1.00, taxons: [taxon_child]) }

    it "商品の表示確認", js: true do
      visit potepan_category_path(taxon_child.id)

      aggregate_failures do
        select '古い順', from: '並び順'
        within first('.productBox') do
          expect(page).to have_selector 'h5', text: "#{old_product.name}", visible: false
        end

        select '安い順', from: '並び順'
        within first('.productBox') do
          expect(page).to have_selector 'h5', text: "#{cheap_product.name}", visible: false
        end

        select '高い順', from: '並び順'
        within first('.productBox') do
          expect(page).to have_selector 'h5', text: "#{expensive_product.name}", visible: false
        end

        select '新着順', from: '並び順'
        within first('.productBox') do
          expect(page).to have_selector 'h5', text: "#{new_product.name}", visible: false
        end
      end
    end
  end
end
