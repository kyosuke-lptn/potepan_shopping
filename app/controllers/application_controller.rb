class ApplicationController < ActionController::Base
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::Store
  include Spree::Core::ControllerHelpers::PaymentParameters
  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::StrongParameters

  protect_from_forgery with: :exception

  private

  def lock_order
    Spree::OrderMutex.with_lock!(@order) { yield }
  rescue Spree::OrderMutex::LockFailed
    flash[:error] = t('spree.order_mutex_error')
    redirect_to potepan_cart_path
  end
end
