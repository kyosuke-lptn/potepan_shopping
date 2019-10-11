require 'rails_helper'

RSpec.describe "Potepan::Orders", type: :request do
  let!(:variant) { create(:variant) }
  let!(:store) { create(:store) }

  before do
    current_store = store # rubocop: disable Lint/UselessAssignment
  end

  describe "POST /potepan/orders/create" do
    context '既存のorderがない' do
      it "新しいorderが作成される" do
        expect do
          post potepan_orders_path, params: { variant_id: variant.id, quantity: "2" }
        end.to change(Spree::Order, :count).by(1)
        created_order = Spree::Order.last
        expect(created_order.line_items.size).to eq(1)
        line_itme = created_order.line_items.first
        expect(line_itme.variant_id).to eq(variant.id)
        expect(line_itme.quantity).to eq(2)
      end
    end

    context '既存のorderがある' do
      let!(:order) do
        create(:order, bill_address: nil, ship_address: nil, store: store)
      end

      before do
        current_order_stub
      end

      it "既存のorderにlineitemが追加される" do
        expect do
          post potepan_orders_path, params: { variant_id: variant.id, quantity: "2" }
        end.not_to change(Spree::Order, :count)
        expect(order.line_items.size).to eq(1)
        line_itme = order.line_items.first
        expect(line_itme.variant_id).to eq(variant.id)
        expect(line_itme.quantity).to eq(2)
      end

      context 'lineitemを追加中にエラーが発生した場合' do
        it "homeページにリダイレクトされる" do
          post potepan_orders_path, params: { variant_id: variant.id, quantity: "-1" }
          expect(response).to redirect_to(potepan_root_path)
        end
      end
    end
  end

  describe "GET /potepan/cart" do
    let(:user) { create(:user) }
    let(:order) do
      create(:order_with_line_items, user: nil, bill_address: nil, ship_address: nil, store: store)
    end

    context 'ユーザーがいる場合' do
      before do
        current_order_stub
        sign_in user
      end

      it "まだユーザーに紐づいていない既存のorderにユーザー情報が追加される" do
        get potepan_cart_path
        expect(order.user).to eq(user)
      end
    end
  end

  describe "POST /potepan/orders/:number/update" do
    let!(:order) { create(:order) }

    context '#assign_order' do
      it "current_orderがなくリダイレクトされる" do
        patch potepan_order_path(order)
        expect(response).to redirect_to(potepan_root_path)
      end
    end

    context '#order_params' do
      before do
        current_order_stub
      end

      it "paramsが正しくないため、リダイレクトされる" do
        patch potepan_order_path(order), params:  {
          order:  {
            line_items_attributes:  {
              id: nil,
              variant: "variant_id",
              quantity: "1",
            },
          },
        }
        expect(response).to redirect_to(potepan_cart_path)
      end
    end
  end

  def current_order_stub
    allow(Spree::Order).to receive_message_chain('incomplete.lock.find_by').and_return(order)
  end
end
