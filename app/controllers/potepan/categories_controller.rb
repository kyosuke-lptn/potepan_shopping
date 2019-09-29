class Potepan::CategoriesController < ApplicationController
  def show
    @scope = Spree::Product.all
    if params[:color].present?
      @title = "Color / #{params[:color]}"
      @products = @scope.filter_by_option_value(params[:color]).with_images_and_prices
    else
      @taxon = Spree::Taxon.find(params[:id])
      @title = @taxon.name
      @products = @scope.filter_by_taxon(@taxon).with_images_and_prices
    end
    @taxonomies = Spree::Taxonomy.includes(root: :children)
    @option_type = Spree::OptionType.value_name("Color")
  end
end
