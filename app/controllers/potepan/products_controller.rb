class Potepan::ProductsController < ApplicationController
  def show
    @product = Spree::Product.available.friendly.find(params[:id])
    @product_images = (@product.images + @product.variant_images).uniq || []
    @taxons = @product.taxons
    if @taxons.empty?
      @taxon_products = []
    else
      product_ids = @taxons.map do |taxon|
        taxon.products.where.not(id: @product.id).ids
      end.flatten!.uniq
      @taxon_products = Spree::Product.
        includes(master: [:images, :currently_valid_prices]).
        where(id: product_ids[0..3])
    end
  end
end
