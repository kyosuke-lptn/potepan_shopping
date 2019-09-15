module Potepan
  module CategoriesHelper
    def taxons_list(taxonomies)
      tag.ul class: "nav navbar-nav side-nav", id: "categories" do
        taxonomies.each do |taxonomy|
          taxon_root =  taxonomy.root
          concat(
            tag.li do
              concat(link_to("javascript:;", id: "category-parent", data: {
                toggle: "collapse",
                target: "\##{taxon_root.name}",
              })do
                concat taxon_root.name
                concat tag.i class: "fa fa-plus"
              end)
              concat child_list(taxon_root)
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
              if child.children.empty?
                link_to potepan_category_path(child.id) do
                  concat tag.i(class: "fa fa-angle-right", aria: { hidden: true })
                  concat child.name
                  concat tag.span "(#{child.all_products.count})"
                end
              else
                concat(link_to("javascript:;", id: "category-child", data: {
                  toggle: "collapse",
                  target: "\##{child.name}",
                })do
                  concat child.name
                  concat tag.i class: "fa fa-caret-right"
                end)
                concat(
                  tag.ul(id: child.name, class: "collapse collapseItem")do
                    child.children.each do |grandchild|
                      concat(
                        tag.li(class: "grandchild") do
                          link_to potepan_category_path(grandchild.id) do
                            concat tag.i(class: "fa fa-angle-right", aria: { hidden: true })
                            concat grandchild.name
                            concat tag.span "(#{grandchild.active_products.count})"
                          end
                        end
                      )
                    end
                  end
                )
              end
            end
          )
        end
      end
    end
  end
end
