require 'rails_helper'

describe 'Search機能', type: :system do
  let!(:bag) { create(:product, name: "Bag") }
  let!(:t_shirt) { create(:product, name: "T-shirt") }

  it "検索ワードにヒットした製品が並ぶ" do
    visit potepan_root_path
    fill_in 'Search…', with: ''
    click_on '検索'

    aggregate_failures do
      expect(page).to have_content "に該当する商品が見つかりませんでした"
      expect(page).not_to have_content bag.name
      expect(page).not_to have_content t_shirt.name

      fill_in 'Search…', with: 'bag'
      click_on '検索'

      expect(page).to have_content bag.name
      expect(page).not_to have_content t_shirt.name
    end
  end
end
