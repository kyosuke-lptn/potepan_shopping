require 'rails_helper'

describe 'checkout機能', type: :system do
  let!(:order) { create(:order_with_line_items, store: store) }
  let!(:country) { create(:country, name: "Japan") }
  let!(:state) { create(:state, name: "Hyogo") }
  let(:store) { create(:store) }

  before do
    current_store = store # rubocop: disable Lint/UselessAssignment
    allow(Spree::Order).to receive_message_chain('incomplete.lock.find_by').and_return(order)
  end

  it "お客様の情報入力手順" do
    visit potepan_cart_path
    find('#purchase').click

    aggregate_failures do
      expect(page).to have_link 'back'
      fill_in '姓', with: ''
      fill_in '名', with: ''
      fill_in 'メールアドレス', with: ''
      fill_in '電話番号', with: ''
      fill_in '郵便番号', with: ''
      fill_in '市', with: ''
      fill_in '住所', with: ''
      click_button '次へ'

      expect(page).to have_content 'お届け先情報'
      expect(page).to have_content "5　個のエラーがあります。"
      fill_in '姓', with: '山田'
      fill_in '名', with: '太郎'
      fill_in 'メールアドレス', with: 'foo@bar.com'
      fill_in '電話番号', with: '000-0000-0000'
      fill_in '郵便番号', with: '000-0000'
      select 'Japan', from: 'order_ship_address_attributes_country_id'
      select 'Hyogo', from: 'order_ship_address_attributes_state_id'
      fill_in '市', with: '神戸市'
      fill_in '住所', with: '●●区●●町0-00'
      click_button '次へ'
      expect(page).to have_content 'お支払い方法'
    end
  end
end
