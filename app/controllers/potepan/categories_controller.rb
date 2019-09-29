class Potepan::CategoriesController < ApplicationController
  def show
    scope = Spree::Product.all
    if params[:color].present?
      @title = "Color / #{params[:color]}"
      scope = scope.filter_by_option_value(params[:color])
    else
      @taxon = Spree::Taxon.find(params[:id])
      @title = @taxon.name
      scope = scope.filter_by_taxon(@taxon)
    end
    @products = scope.with_images_and_prices
    @taxonomies = Spree::Taxonomy.includes(root: :children)
  end
end
