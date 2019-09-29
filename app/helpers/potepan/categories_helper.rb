module Potepan
  module CategoriesHelper
    def taxons_list(taxonomies)
      tag.ul id: "categories", class: "nav navbar-nav side-nav" do
        taxonomies.each do |taxonomy|
          taxon_root =  taxonomy.root
          list_connection(taxon_root, a_id: "category-parent") do
            tag.ul id: taxon_root.name, class: "collapse collapseItem" do
              taxon_root.children.each do |child|
                if child.children.empty?
                  concat lowest_list(child)
                else
                  list_connection(child, a_id: "category-child") do
                    tag.ul(id: child.name, class: "collapse collapseItem") do
                      child.children.each do |grandchild|
                        concat lowest_list(grandchild, li_class: "grandchild")
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    def lowest_list(taxon, li_class: nil)
      tag.li(class: "#{li_class}") do
        link_to potepan_category_path(taxon.id) do
          concat tag.i(class: "fa fa-angle-right", aria: { hidden: true })
          concat taxon.name
          concat tag.span "(#{taxon.active_products.count})"
        end
      end
    end

    def list_connection(taxon, a_id: nil)
      icon_class = (a_id == "category-parent") ? "fa fa-plus" : "fa fa-caret-right"
      concat(
        tag.li do
          concat(
            link_to("javascript:;", id: a_id, data: {
              toggle: "collapse",
              target: "\##{taxon.name}",
            }) do
              concat taxon.name
              concat tag.i class: icon_class
            end
          )
          concat(
            yield
          )
        end
      )
    end

    def colors
      Spree::OptionType.includes(:option_values).where(presentation: "Color").map{|type|type.option_values.pluck(:name)}.flatten.uniq
    end
  end
end
