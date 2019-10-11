module Potepan::VariantDecorator
  def selectable_quantity
    total = total_on_hand
    total > 10 ? [*1..10] : [*1..total]
  end

  Spree::Variant.prepend self
end
