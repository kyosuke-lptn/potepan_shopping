class Potepan::ProductsController < Spree::ProductsController
  append_before_action :load_variables, only: :show

  private

  def load_variables
    @product_images = (@product.images + @product.variant_images).uniq || []
    if taxons = @product.taxons
      product_ids = taxons.map{|taxon| taxon.products.where.not(id: @product.id).ids }.flatten!.uniq
      @taxon_products = Spree::Product.includes(master: [:images, :currently_valid_prices]).where(id: product_ids)
    else
      @taxon_products = []
    end
  end
end
