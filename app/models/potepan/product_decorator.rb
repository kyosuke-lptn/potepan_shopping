module Potepan::ProductDecorator
  def self.prepended(base)
    base.scope :filter_by_taxon, ->(taxon_id) do
      joins(:taxons).
        where("#{Spree::Taxon.table_name}.id = ?", taxon_id)
    end

    base.scope :filter_by_option_value, ->(option_value) do
      joins(variants: :option_values).
        where("#{Spree::OptionValue.table_name}.presentation = ?", option_value).
        group(:id)
    end

    base.scope :with_images_and_prices, -> { includes(master: [:images, :currently_valid_prices]) }
  end

  Spree::Product.prepend self
end
