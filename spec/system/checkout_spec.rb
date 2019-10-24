require 'rails_helper'

describe 'checkout機能', type: :system do
  include ActiveJob::TestHelper

  context '配送範囲内からの注文の場合' do
    let(:credit_card) { create(:credit_card) }

    before(:each) do
      @order = OrderWalkthrough_up_to(:address)
      user = create(:user)
      @order.user = user
      @order.recalculate
      allow_any_instance_of(Potepan::CheckoutController).
        to receive_messages(try_spree_current_user: user)
      allow_any_instance_of(Potepan::OrdersController).
        to receive_messages(try_spree_current_user: user)
      allow_any_instance_of(Potepan::CheckoutController).
        to receive_messages(current_order: @order)
      allow_any_instance_of(Potepan::OrdersController).
        to receive_messages(current_order: @order)
      allow_any_instance_of(Potepan::OrdersController).
        to receive_messages(current_store: @store)
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

        expect(page).to have_content '姓'
        expect(page).to have_content "5　個のエラーがあります。"
        correct_address_form

        expect(page).to have_content 'カード名義人'
        expect(page).to have_content 'カード番号'
        hidden_value = find('#order_payments_attributes__payment_method_id',
                            visible: false).value
        @order.reload
        expect(hidden_value).to eq @order.available_payment_methods.first.id.to_s
        expect(page).to have_link 'back'
        fill_in "カード名義人", with: credit_card.name
        fill_in "カード番号", with: credit_card.number
        fill_in "セキュリティコード", with: credit_card.verification_value
        select credit_card.month, from: "payment_source[#{@payment_method.id}][expiry][value(2i)]"
        select credit_card.year, from: "payment_source[#{@payment_method.id}][expiry][value(1i)]"
        click_on "次へ"

        @order.line_items.each do |item|
          expect(page).to have_content item.name
          expect(page).to have_content item.quantity
        end
        expect(page).to have_link "back"
        expect(page).to have_content "総計"
        expect(current_path).to eq potepan_checkout_state_path("confirm")
        perform_enqueued_jobs do
          click_link "購入確定"

          @order.reload
          expect(page).to have_content "Thank You !! ご注文ありがとうございます。"
          expect(page).to have_content @order.number
          expect(current_path).to eq potepan_order_path(@order)
        end

        mail = ActionMailer::Base.deliveries.last

        expect(mail.to).to eq [@order.email]
        expect(mail.from).to eq [@store.mail_from_address]
        expect(mail.subject).to match "ご注文の確認"
      end
    end

    context "誤ったpayment情報を送信していた場合" do
      let(:fail_card) { create(:credit_card, :failing) }

      it "completeできずエラーが発生" do
        visit potepan_cart_path
        find('#purchase').click
        correct_address_form
        fill_in "カード名義人", with: fail_card.name
        fill_in "カード番号", with: fail_card.number
        fill_in "セキュリティコード", with: fail_card.verification_value
        select fail_card.month, from: "payment_source[#{@payment_method.id}][expiry][value(2i)]"
        select fail_card.year, from: "payment_source[#{@payment_method.id}][expiry][value(1i)]"
        click_on "次へ"
        click_on "購入確定"
        expect(page).to have_content "エラーが発生したため、次の処理に進めませんでした。"
      end
    end

    context "pyament情報が空白であった場合" do
      it "confirmページに移行できずエラーが発生" do
        visit potepan_cart_path
        find('#purchase').click
        correct_address_form
        fill_in "カード名義人", with: ""
        fill_in "カード番号", with: ""
        fill_in "セキュリティコード", with: ""
        click_button '次へ'

        expect(page).to have_content "3　個のエラーがあります。"
      end
    end
  end

  def correct_address_form
    fill_in '姓', with: '山田'
    fill_in '名', with: '太郎'
    fill_in 'メールアドレス', with: 'foo@bar.com'
    fill_in '電話番号', with: '000-0000-0000'
    fill_in '郵便番号', with: '000-0000'
    state = Spree::State.first
    country = state.country
    select country.name, from: 'order_ship_address_attributes_country_id'
    select state.name, from: 'order_ship_address_attributes_state_id'
    fill_in '市', with: '神戸市'
    fill_in '住所', with: '●●区●●町0-00'
    click_button '次へ'
  end
end
