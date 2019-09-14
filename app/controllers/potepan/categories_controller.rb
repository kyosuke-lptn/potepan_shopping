class Potepan::CategoriesController < Spree::StoreController
  def show
    @taxon = Spree::Taxon.find(params[:id])
    searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
    @products = searcher.retrieve_products
    taxonomy = Spree::Taxonomy.includes(root: { children: :products }).find_by(name: 'Categories')
    @taxon_root = taxonomy.root.children
  end
end
