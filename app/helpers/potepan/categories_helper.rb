module Potepan
  module CategoriesHelper
    def taxons_list(taxonomies)
      tag.ul class: "nav navbar-nav side-nav" do
        taxonomies.each do |taxonomy|
          taxon_root = taxonomy.root
          concat(
            tag.li do
              link_to "javascript:;", data: {
                toggle: "collapse",
                target: "\##{taxon_root.name}",
              } do
                concat taxon_root.name
                concat tag.i class: "fa fa-plus"
                concat child_list(taxon_root)
              end
            end
          )
        end
      end
    end

    def child_list(taxon)
      tag.ul id: taxon.name, class: "collapse collapseItem" do
        taxon.children.each do |child|
          concat(
            tag.li do
              link_to potepan_category_path(child.id) do
                concat tag.i(class: "fa fa-caret-right", aria: { hidden: true })
                concat child.name
                concat tag.span "(#{child.all_products.count})"
              end
            end
          )
        end
      end
    end
  end
end
