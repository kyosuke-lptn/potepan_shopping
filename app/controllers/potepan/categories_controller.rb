class Potepan::CategoriesController < ApplicationController
  def show
    @taxon = Spree::Taxon.find(params[:id])
    @products = Spree::Product.
      includes(master: [:images, :currently_valid_prices]).
      where(id: @taxon.all_products.ids)
    @taxonomies = Spree::Taxonomy.includes(root: :children)
  end
end
