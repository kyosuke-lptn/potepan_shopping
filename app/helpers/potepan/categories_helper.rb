module Potepan
  module CategoriesHelper
    def taxons_list(taxon_root)
      tag.ul class: "nav navbar-nav side-nav", id: "categories" do
        taxon_root.each do |taxon|
          concat(
            tag.li do
              link_to "javascript:;", data: {
                toggle: "collapse",
                target: "\##{taxon.name}",
              } do
                concat taxon.name
                concat tag.i class: "fa fa-plus"
                concat child_list(taxon)
              end
            end
          )
        end
      end
    end

    def child_list(taxon)
      tag.ul id: taxon.name, class: "collapse collapseItem" do
        if taxon.children.empty?
          taxon.products.each do |product|
            concat(
              tag.li do
                link_to potepan_product_path(product) do
                  concat tag.i(class: "fa fa-caret-right", aria: { hidden: true })
                  concat product.name
                end
              end
            )
          end
        else
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
end
