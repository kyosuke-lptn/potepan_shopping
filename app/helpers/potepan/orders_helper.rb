module Potepan
  module OrdersHelper
    def line_item_name(line_item)
      option_value = line_item.variant.options_text
      if line_item.variant.is_master?
        line_item.name
      else
        "#{line_item.name} (#{option_value})"
      end
    end
  end
end
