require 'rails_helper'

RSpec.describe "Potepan::Checkout", type: :request do
  let!(:store) { create(:store) }
  let!(:country) { create(:country, name: "Japan") }

  before do
    current_store = store # rubocop: disable Lint/UselessAssignment
  end

  describe "GET /potepan/checkout/address" do
    let!(:order) { create(:order_with_line_items, state: "address") }

    context 'current_orderがある' do
      before do
        current_order_stub(order)
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
          current_order_stub(completed_oreder)
          get potepan_checkout_state_path(order.state)
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

      before do
        current_order_stub(order_nil_user)
        sign_in user
      end

      it "orderにユーザー情報が追加される" do
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

  describe "GET /potepan/checkout/address" do
    let!(:address_order) { create(:order_with_line_items, state: "address") }
    let!(:input_country) { create(:country) }
    let!(:state) { create(:state, country: input_country) }

    before do
      current_order_stub(address_order)
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
        addres = address_order.ship_address
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

  def current_order_stub(order)
    allow(Spree::Order).to receive_message_chain('incomplete.lock.find_by').and_return(order)
  end
end
