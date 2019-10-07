class ApplicationController < ActionController::Base
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::Store
  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::StrongParameters

  before_action :get_current_order, if: -> { @order.blank? }

  protect_from_forgery with: :exception

  private

  def get_current_order
    @order = current_order
  end
end
