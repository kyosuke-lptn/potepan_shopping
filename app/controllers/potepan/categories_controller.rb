class Potepan::CategoriesController < ApplicationController
  def show
    @taxon = Spree::Taxon.find(params[:id])
    @search_form = ProductSearchForm.new(taxon: @taxon, color: params[:color])
    @products = @search_form.search
    @taxonomies = Spree::Taxonomy.includes(root: :children)
    @option_type = Spree::OptionType.value_name("Color")
  end
end
