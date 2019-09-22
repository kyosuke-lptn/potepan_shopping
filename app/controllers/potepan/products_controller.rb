class Potepan::ProductsController < ApplicationController
  def show
    @product = Spree::Product.available.friendly.find(params[:id])
    @product_images = (@product.images + @product.variant_images).uniq || []
    @taxons = @product.taxons
  end
end
