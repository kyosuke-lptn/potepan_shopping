class Potepan::LineItemsController < ApplicationController
  before_action :assign_order

  def destroy
    @line_item = Spree::LineItem.find params[:id]
    @order.contents.remove_line_item(@line_item)
    @order.reload.line_items.present?
  end

  private

  def assign_order
    @order = current_order
    redirect_to(potepan_root_path) and return unless @order # rubocop: disable Style/AndOr
  end
end
