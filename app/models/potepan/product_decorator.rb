module Potepan::ProductDecorator
  MAX_SEARCH_PRODUCT_DISPLAY = 9

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

    base.scope :words_search, ->(words) do
      return [] if words.blank?
      regexp = "%#{words.strip.gsub(/[ 　\t]+/, "%")}%"
      products = []
      products << where("name LIKE :this OR description LIKE :this", this: regexp).with_images_and_prices
      regexp_words = words.split(/[ 　\t]/).map{ |a| "%#{a.strip}%" }.each do |word|
        return if products.length > MAX_SEARCH_PRODUCT_DISPLAY
        limit_number = MAX_SEARCH_PRODUCT_DISPLAY - products.length.to_i
        exclusion_ids = products.flatten.map(&:id).uniq
        products << where("name LIKE :this OR description LIKE :this", this: word).where.not(id: exclusion_ids).limit(limit_number).with_images_and_prices
      end
      products.flatten
    end
  end

  Spree::Product.prepend self
end
