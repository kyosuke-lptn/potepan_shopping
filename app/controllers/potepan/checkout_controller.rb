class Potepan::CheckoutController < ApplicationController
  before_action :load_order, only: [:edit, :update]
  around_action :lock_order, only: [:edit, :update]
  before_action :set_state_if_present, only: [:edit, :update]
  before_action :ensure_order_not_completed, only: [:edit, :update]
  before_action :ensure_checkout_allowed, only: [:edit, :update]
  before_action :ensure_sufficient_stock_lines, only: [:edit, :update]
  before_action :ensure_valid_state, only: [:edit, :update]
  before_action :associate_user, only: [:edit, :update]
  before_action :setup_for_current_state, only: [:edit, :update]

  rescue_from Spree::Core::GatewayError, with: :rescue_from_spree_gateway_error

  def update
    if update_order
      unless transition_forward
        redirect_on_failure
        return
      end
      if @order.completed?
        redirect_to potepan_order_path(@order)
      else
        send_to_next_state
      end
    else
      render :edit
    end
  end

  private

  def update_order
    Spree::OrderUpdateAttributes.new(@order, update_params, request_env: request.headers.env).apply
  end

  def update_params
    if update_params = massaged_params[:order] # rubocop: disable Lint/AssignmentInCondition
      update_params.permit(permitted_checkout_attributes)
    else
      # We currently allow update requests without any parameters in them.
      {}
    end
  end

  def massaged_params
    massaged_params = params.deep_dup
    move_and_modifay_payment_source_into_payments_attributes(massaged_params)
    set_payment_parameters_amount(massaged_params, @order)
    massaged_params
  end

  def move_and_modifay_payment_source_into_payments_attributes(params)
    return params if params[:payment_source].blank?
    payment_params = params[:order] &&
                     params[:order][:payments_attributes] &&
                     params[:order][:payments_attributes].first
    return params if payment_params.blank?
    payment_method_id = payment_params[:payment_method_id]
    return params if payment_method_id.blank?
    expiry_all = params[:payment_source][payment_method_id][:expiry]
    expiry_month = expiry_all["value(2i)"]
    expiry_year = expiry_all["value(1i)"]
    expiry_month = "0#{expiry_month}" if expiry_month.to_i < 10
    expiry = "#{expiry_month} / #{expiry_year}"
    params[:payment_source][payment_method_id][:expiry] = expiry
    source_params = params[:payment_source][payment_method_id]
    return params if source_params.blank?
    payment_params[:source_attributes] = source_params
    params.delete(:payment_source)
    params
  end

  def transition_forward
    if @order.can_complete?
      @order.complete
    else
      @order.next
      @order.next if @order.state == "delivery"
    end
  end

  def redirect_on_failure
    flash[:error] = @order.errors.full_messages.join("\n")
    redirect_to(potepan_checkout_state_path(@order.state))
  end

  def send_to_next_state
    redirect_to potepan_checkout_state_path(@order.state)
  end

  def load_order
    @order = current_order
    redirect_to(potepan_root_path) && return unless @order
  end

  def set_state_if_present
    if params[:state]
      redirect_to potepan_checkout_state_path(@order.state) if @order.can_go_to_state?(params[:state]) # rubocop: disable Metrics/LineLength
      @order.state = params[:state]
    end
  end

  def ensure_order_not_completed
    redirect_to potepan_cart_path if @order.completed?
  end

  def ensure_checkout_allowed
    unless @order.checkout_allowed?
      redirect_to potepan_cart_path
    end
  end

  def ensure_sufficient_stock_lines
    if @order.insufficient_stock_lines.present?
      out_of_stock_items = @order.insufficient_stock_lines.collect(&:name).to_sentence
      flash[:error] = t(
        'spree.inventory_error_flash_for_insufficient_quantity', names: out_of_stock_items
      )
      redirect_to potepan_cart_path
    end
  end

  def ensure_valid_state
    if (params[:state] && !@order.has_checkout_step?(params[:state])) ||
       (!params[:state] && !@order.has_checkout_step?(@order.state))
      @order.state = 'cart'
      redirect_to potepan_checkout_state_path(@order.checkout_steps.first)
    end
  end

  def setup_for_current_state
    method_name = :"before_#{@order.state}"
    send(method_name) if respond_to?(method_name, true)
  end

  def before_address
    @order.assign_default_user_addresses
    # If the user has a default address, the previous method call takes care
    # of setting that; but if he doesn't, we need to build an empty one here
    default = { country_id: Spree::Country.find_by(name: "Japan").id }
    @order.build_bill_address(default) unless @order.bill_address
    @order.build_ship_address(default) if @order.checkout_steps.include?('delivery') && !@order.ship_address # rubocop: disable Metrics/LineLength, Airbnb/SimpleModifierConditional
  end

  def before_payment
    if @order.checkout_steps.include? "delivery"
      packages = @order.shipments.map(&:to_package)
      differentiator = Spree::Stock::Differentiator.new(@order, packages)
      differentiator.missing.each do |variant, quantity|
        @order.contents.remove(variant, quantity)
      end
    end
    @payment_method_id = @order.available_payment_methods.first.id
  end

  def rescue_from_spree_gateway_error(exception)
    flash.now[:error] = t('spree.spree_gateway_error_flash_for_checkout')
    @order.errors.add(:base, exception.message)
    redirect_to potepan_checkout_state_path("payment")
  end
end
