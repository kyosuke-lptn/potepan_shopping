require 'rails_helper'

RSpec.describe "Potepan::Checkout", type: :request do
  describe "GET /potepan/checkout/address" do
    let!(:order) { create(:order_with_line_items, state: "address") }
    let!(:country) { create(:country, name: "Japan") }

    context 'current_orderがある' do
      before do
        allow_any_instance_of(Potepan::CheckoutController).
          to receive_messages(current_order: order)
      end

      it "正常に動作する" do
        get potepan_checkout_state_path(order.state)
        expect(response).to have_http_status(200)
      end

      it "lock_orderでエラーが発生しリダイレクトされる" do
        expect(Spree::OrderMutex).
          to receive_message_chain('expired.where.delete_all').
          and_raise(Spree::OrderMutex::LockFailed)
        get potepan_checkout_state_path(order.state)
        expect(response).to redirect_to(potepan_cart_path)
      end

      context "orderのstateよりもparamsメータの方が状態が進んでいた時" do
        it "paramsの値までstateを引き上げる" do
          expect do
            get potepan_checkout_state_path("delivery")
          end.to change(order, :state).from("address").to("delivery")
        end
      end

      context "orderがcompleteしていた場合" do
        let!(:completed_oreder) { create(:completed_order_with_totals) }

        it "cartページにリダイレクトされる" do
          allow_any_instance_of(Potepan::CheckoutController).
            to receive_messages(current_order: completed_oreder)
          get potepan_checkout_state_path(completed_oreder.state)
          expect(response).to redirect_to(potepan_cart_path)
        end
      end

      context "lineitemが存在しない場合" do
        it "cartページにリダイレクトされる" do
          order.line_items.destroy_all
          get potepan_checkout_state_path(order.state)
          expect(response).to redirect_to(potepan_cart_path)
        end
      end

      context "商品が供給できない場合" do
        let!(:variant) { order.line_items.first.variant }
        let(:stock_item) { variant.stock_items.first }

        it "cartページにリダイレクトされる" do
          stock_item.backorderable = false
          stock_item.set_count_on_hand(0)
          get potepan_checkout_state_path(order.state)
          expect(response).to redirect_to(potepan_cart_path)
        end
      end

      context "params[:state]の値が誤っている場合" do
        it "order.stateをカートに設定してリダイレクトされる" do
          expect do
            get potepan_checkout_state_path("test")
          end.to change(order, :state).from("address").to("cart")
        end
      end
    end

    context 'current_orderがない' do
      it "homeぺージへリダイレクトされる" do
        get potepan_checkout_state_path(order.state)
        expect(response).to redirect_to(potepan_root_path)
      end
    end

    context 'orderがユーザーに紐づいていない場合' do
      let(:user) { create(:user, ship_address: ship_address, bill_address: bill_address) }
      let(:order_nil_user) do
        create(:order_with_line_items,
               user: nil,
               email: nil,
               bill_address: nil,
               ship_address: nil,
               state: "address")
      end
      let(:bill_address) { create(:address) }
      let(:ship_address) { create(:address) }

      it "orderにユーザー情報が追加される" do
        allow_any_instance_of(Potepan::CheckoutController).
          to receive_messages(current_order: order_nil_user)
        sign_in user
        get potepan_checkout_state_path(order_nil_user.state)
        aggregate_failures do
          expect(order_nil_user.user).to eq(user)
          expect(order_nil_user.email).to eq(user.email)
          expect(order_nil_user.bill_address).to eq(bill_address)
          expect(order_nil_user.ship_address).to eq(ship_address)
        end
      end
    end
  end

  describe "PATCH /potepan/checkout/address" do
    let!(:address_order) { create(:order_with_line_items, state: "address") }
    let!(:country) { create(:country, name: "Japan") }
    let!(:input_country) { create(:country) }
    let!(:state) { create(:state, country: input_country) }

    before do
      allow_any_instance_of(Potepan::CheckoutController).
        to receive_messages(current_order: address_order)
    end

    it "正常に動作し、データが更新される" do
      patch potepan_update_checkout_path(address_order.state),
            params:  {
              order:  {
                ship_address_attributes:  {
                  lastname: "potepan",
                  firstname: "taro",
                  phone: "012-0123-0123",
                  zipcode: "111-2222",
                  city: "kobe",
                  address1: "address",
                  id: address_order.id,
                  country_id: input_country.id,
                  state_id: state.id,
                },
                email: "foo@bar.com",
              },
            }
      aggregate_failures do
        addres = address_order.reload.ship_address
        expect(addres.firstname).to eq "taro"
        expect(addres.lastname).to eq "potepan"
        expect(addres.phone).to eq "012-0123-0123"
        expect(addres.zipcode).to eq "111-2222"
        expect(addres.city).to eq "kobe"
        expect(addres.address1).to eq "address"
        expect(address_order.email).to eq "foo@bar.com"
        expect(addres.country_id).to eq input_country.id
        expect(addres.state_id).to eq state.id
      end
    end
  end

  describe "PATCH /potepan/checkout/payment" do
    let(:payment_order) { OrderWalkthrough_up_to(:delivery) }

    before do
      user = create(:user)
      payment_order.user = user
      payment_order.recalculate
      allow_any_instance_of(Potepan::CheckoutController).
        to receive_messages(current_order: payment_order)
    end

    it "正常に動作し、データが更新される" do
      payment_correct_params(payment_order)
      aggregate_failures do
        expect(payment_order.state).to eq "confirm"
        payment = payment_order.reload.payments.last
        expect(payment.order_id).to eq payment_order.id
        expect(payment.payment_method_id).to eq @payment_method.id
        expect(payment.amount).to eq payment_order.total
        payment_source = payment.source
        expect(payment_source.month).to eq "10"
        expect(payment_source.year).to eq "2019"
        expect(payment_source.last_digits).to eq "1111"
        expect(payment_source.name).to eq "taro potepan"
        expect(payment_source.user_id).to eq payment_order.user.id
        expect(payment_source.payment_method_id).to eq @payment_method.id
      end
    end

    context "連続でpaymentデータを送信した場合" do
      it "既存のpaymentデータはinvalidになる" do
        payment_correct_params(payment_order)
        aggregate_failures do
          expect(payment_order.payments.length).to eq 1
          payment_correct_params(payment_order)
          expect(payment_order.payments.length).to eq 2
          expect(payment_order.payments.first.state).to eq "invalid"
        end
      end
    end

    context "inventory_unitとlineitemの数量が異なる場合" do
      before do
        payment_order.line_items.first.update_column(:quantity, 3)
      end

      it "inventory_unitの数量と合わされる" do
        payment_correct_params(payment_order)
        inventory_count = payment_order.inventory_units.length
        expect(payment_order.reload.line_items.first.quantity).to eq inventory_count
      end
    end
  end

  def payment_correct_params(order)
    payment_method_id = order.available_payment_methods.first.id
    patch potepan_update_checkout_path(order.state),
          params: {
            order: {
              payments_attributes: [
                { "payment_method_id" => payment_method_id },
              ],
            },
            payment_source: {
              payment_method_id => {
                name: "taro potepan",
                number: "4111111111111111",
                expiry: {
                  "value(3i)" => "1",
                  "value(2i)" => "10",
                  "value(1i)" => "2019",
                },
                verification_value: "000",
              },
            },
          }
  end

  describe "PATCH /potepan/checkout/confirm" do
    let!(:confirm_order) { OrderWalkthrough_up_to(:payment) }

    before do
      allow_any_instance_of(Potepan::CheckoutController).
        to receive_messages(current_order: confirm_order)
      allow_any_instance_of(Potepan::CheckoutController).
        to receive_messages(current_store: @store)
    end

    context "completeに成功した時" do
      it "stateがcompleteになる" do
        patch potepan_update_checkout_path(confirm_order.state)
        confirm_order.reload
        expect(confirm_order.state).to eq "complete"
      end
    end

    context "completeに失敗した時" do
      it "confirmページにレダイレクトされる" do
        allow(confirm_order).to receive(:complete).and_return(false)
        patch potepan_update_checkout_path(confirm_order.state)
        expect(response).to redirect_to potepan_checkout_state_path("confirm")
      end
    end
  end
end
