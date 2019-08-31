class Potepan::ProductsController < Spree::ProductsController
  append_before_action :product_images, only: :show

  private

  def product_images
    @product_images = (@product.images + @product.variant_images).uniq || [@product.display_image]
  end
end
