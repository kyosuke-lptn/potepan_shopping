class Potepan::CategoriesController < Spree::StoreController
  def show
    @taxon = Spree::Taxon.find_by!(id: params[:id])
    searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
    @products = searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)
  end
end
