class ProductSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :taxon
  attribute :color, :string
  attribute :size, :string

  def search
    scope = Spree::Product.all
    scope = scope.filter_by_taxon(taxon)
    if color.present?
      scope = scope.filter_by_option_value(color)
    elsif size.present?
      scope = scope.filter_by_option_value(size)
    end
    scope.with_images_and_prices.order(available_on: :desc, name: :asc)
  end
end
