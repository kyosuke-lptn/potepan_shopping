module Potepan
  module ProductsHelper
    def taxon_link(product_taxons)
      if product_taxons.empty?
        potepan_path
      else
        potepan_category_path(product_taxons.ids[0])
      end
    end
  end
end
