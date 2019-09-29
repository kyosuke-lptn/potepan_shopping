require 'rails_helper'

describe 'Categories機能', type: :system do
  let!(:product) { create(:product, taxons: [taxon_child]) }
  let(:taxonomy) { create(:taxonomy, name: 'Categories') }
  let(:taxon) { create(:taxon, parent_id: taxonomy.root.id, taxonomy: taxonomy) }
  let(:taxon_child) { create(:taxon, parent_id: taxon.id, taxonomy: taxonomy) }
  let!(:value_color) do
    create(:option_value, name: "Red", presentation: "Red", option_type: type_color)
  end
  let!(:type_color) { create(:option_type, presentation: "Color") }
  let!(:red_product) { create(:product, variants: [red_variant]) }
  let(:red_variant) { create(:variant, option_values: [value_color]) }

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

  it "色指定した場合の表示確認" do
    visit potepan_category_path(taxon.id)
    click_link 'Red'

    aggregate_failures do
      expect(page).to have_content red_product.name
      expect(page).not_to have_content product.name
    end
  end
end
