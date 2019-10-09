class Potepan::OrdersController < ApplicationController
  before_action :store_guest_token
  before_action :assign_order, only: :update
  before_action :order_params, only: :update

  def create
    @order = current_order(create_order_if_necessary: true)
    variant  = Spree::Variant.find(params[:variant_id])
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1
    # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
    if !quantity.between?(1, 2_147_483_647)
      @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
    end
    begin
      @line_item = @order.contents.add(variant, quantity)
    rescue ActiveRecord::RecordInvalid => e
      @order.errors.add(:base, e.record.errors.full_messages.join(", "))
    end
    if @order.errors.any?
      flash[:error] = @order.errors.full_messages.join(", ")
      redirect_back(fallback_location: potepan_root_path) and return # rubocop: disable Style/AndOr
    else
      redirect_to potepan_cart_path
    end
  end

  def edit
    @order = current_order || Spree::Order.incomplete.find_or_initialize_by(
      guest_token: cookies.signed[:guest_token]
    )
    associate_user
  end

  def update
    if @order.contents.update_cart(order_params)
      @order.next if params.key?(:checkout) && @order.cart? # rubocop: disable Airbnb/SimpleModifierConditional, Metrics/LineLength
      if params.key?(:checkout)
        redirect_to potepan_checkout_state_path(@order.checkout_steps.first) and return # rubocop: disable Style/AndOr, Metrics/LineLength
      end
    end
    redirect_to potepan_cart_path
  end

  private

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end

  def order_params
    if params[:order]
      params[:order].permit(*permitted_order_attributes)
    else
      {}
    end
  end

  def assign_order
    @order = current_order
    redirect_to(potepan_root_path) and return unless @order # rubocop: disable Style/AndOr
  end
end
