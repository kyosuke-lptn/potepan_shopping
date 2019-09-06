module Potepan
  module TaxonsHelper
    def taxons_list(taxonomy_root_children)
      tag.ul class: "nav navbar-nav side-nav" do
        taxonomy_root_children.each do |taxon|
          if taxon.children.empty?
            link_argument = potepan_taxons_path(taxon)
            text = tag.span "(#{taxon.active_products.count})"
          else
            link_argument = "javascript:;"
            data_argumen  = { :data => { toggle: "collapse", target: "\##{taxon.name}" } }
            text = tag.i class: "fa fa-plus"
          end
          concat(
            tag.li do
              link_to link_argument, data_argumen do
                concat taxon.name
                concat text
                concat child_list(taxon)
              end
            end
          )
        end
      end
    end

    def child_list(taxon)
      return "" if taxon.children.empty?
      tag.ul id: taxon.name, class: "collapse collapseItem" do
        taxon.children.each do |child|
          concat(
            tag.li do
              link_to potepan_taxons_path(child) do
                concat tag.i(class: "fa fa-caret-right", aria: { hidden: true })
                concat child.name
                concat tag.span "(#{child.active_products.count})"
              end
            end
          )
        end
      end
    end
  end
end
