require 'carmen'

module Potepan
  module ProductsHelper
    include Spree::ProductsHelper

    def taxon_link(product_taxons)
      if product_taxons.empty?
        potepan_path
      else
        potepan_category_path(product_taxons.ids[0])
      end
    end

    def display_price(product_or_variant)
      product_or_variant.price_for(Spree::Config.default_pricing_options).to_html
    end

    def taxon_products(product_taxons, exclude_product_id)
      if product_taxons.empty?
        return []
      else
        product_ids = product_taxons.map do |taxon|
          taxon.products.where.not(id: exclude_product_id).ids
        end.flatten!.uniq[0..3]
        Spree::Product.
          includes(master: [:images, :currently_valid_prices]).
          where(id: product_ids)
      end
    end
  end
end
