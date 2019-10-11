require 'carmen'

module Potepan
  module ProductsHelper
    include Spree::ProductsHelper

    def taxon_or_home_link(product_taxons)
      if product_taxons.empty?
        potepan_root_path
      else
        potepan_category_path(product_taxons.ids[0])
      end
    end

    def display_price(product_or_variant)
      product_or_variant.price_for(Spree::Config.default_pricing_options).to_html
    end

    MAXIMUM_NUMBER_OF_DISPLAYS = 4

    def taxon_products(product_taxons, exclude_product_id)
      if product_taxons.empty?
        []
      else
        Spree::Product.in_taxons(product_taxons).distinct.
          with_images_and_prices.
          where.not(id: exclude_product_id).
          limit(MAXIMUM_NUMBER_OF_DISPLAYS)
      end
    end

    def select_box_of_variant(product)
      if product.has_variants?
        select_tag(:variant_id,
                   options_from_collection_for_select(product.variants_and_option_values_for,
                                                      :id,
                                                      :options_text))
      else
        hidden_field_tag(:variant_id, product.master.id)
      end
    end

    def variants_assign(product)
      backorderable_no_stock = []
      no_backorderable_stock = []
      no_backorderable_no_stock = []
      variant_array = product.has_variants? ? product.variants : [product.master]
      variant_array.each do |variant|
        if variant.is_backorderable? && !variant.in_stock?
          backorderable_no_stock << variant.id
        elsif !variant.is_backorderable? && variant.in_stock?
          no_backorderable_stock << variant.id
          concat select_tag :quantity,
                            options_for_select(variant.selectable_quantity, 1),
                            id: "quantity-items#{variant.id}",
                            hidden: true
        elsif !variant.is_backorderable? && !variant.in_stock?
          no_backorderable_no_stock << variant.id
        end
      end
      tag.div(hidden: true) do
        concat tag.div backorderable_no_stock.join(","), id: "backorderable_no_stock"
        concat tag.div no_backorderable_stock.join(","), id: "no_backorderable_stock"
        concat tag.div no_backorderable_no_stock.join(","), id: "no_backorderable_no_stock"
      end
    end
  end
end
