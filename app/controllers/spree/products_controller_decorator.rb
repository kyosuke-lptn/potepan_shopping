Spree::ProductsController.class_eval do
  before_action :product_images, only: :show

  private

  def product_images
    @product_images = (@product.images + @product.variant_images).uniq
  end
end
