require 'rails_helper'

describe 'Categories機能', type: :system do
  let(:product) { create(:product) }
  let!(:taxonomy) { create(:taxonomy, name: 'Categories') }
  let(:taxon) { create(:taxon, parent_id: taxonomy.root.id, taxonomy: taxonomy) }

  before do
    product.taxons << taxon
  end

  it "カテゴリー関連ページの確認" do
    visit potepan_category_path(taxon.id)

    aggregate_failures do
      expect(page).to have_title "#{taxon.name} - BIGBAG Store"
      within '#categories' do
        expect(page).to have_content taxon.products.first.name
        expect(page).to have_content taxon.name
        expect(page).to have_link taxon.name
      end
      expect(page).to have_link product.name
      expect(page).to have_content product.display_price
    end
  end
end
