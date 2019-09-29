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
  end
end
