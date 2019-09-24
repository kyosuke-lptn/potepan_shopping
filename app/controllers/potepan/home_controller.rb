class Potepan::HomeController < ApplicationController
  MAXIMUM_NUMBER_OF_NEW_PRODUCTS = 8
  MAXIMUM_NUMBER_OF_HOT_TAXONS = 3

  def index
    @new_products = Spree::Product.
      includes(master: [:images, :currently_valid_prices]).
      where("available_on > ?", 1.month.ago).
      order(available_on: :desc).
      limit(MAXIMUM_NUMBER_OF_NEW_PRODUCTS)
    @hot_taxons = Spree::Taxon.
      where("meta_keywords=?", "popularity").
      limit(MAXIMUM_NUMBER_OF_HOT_TAXONS)
  end
end
