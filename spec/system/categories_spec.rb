require 'rails_helper'

describe 'Categories機能', type: :system do
  let(:product) { create(:product) }
  let!(:taxonomy) { create(:taxonomy, name: 'Categories') }
  let(:taxon) { create(:taxon, parent_id: taxonomy.root.id, taxonomy: taxonomy) }
  let(:taxon_child) { create(:taxon, parent_id: taxon.id, taxonomy: taxonomy) }

  before do
    product.taxons << taxon_child
  end

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
end
