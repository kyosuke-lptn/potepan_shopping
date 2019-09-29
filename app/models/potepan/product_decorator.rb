module Potepan::ProductDecorator
  def self.prepended(base)
    base.scope :filter_by_taxon, ->(taxon) { where(id: taxon.all_products.ids) }

    base.scope :filter_by_option_value, ->(option_value) do
      joins(variants: :option_values).
        where("#{Spree::OptionValue.table_name}.presentation = ?", option_value).
        group(:id)
    end

    base.scope :with_images_and_prices, -> { includes(master: [:images, :currently_valid_prices]) }
  end

  Spree::Product.prepend self
end
