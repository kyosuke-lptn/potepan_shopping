module Potepan::OptionTypeDecorator
  def self.prepended(base)
    base.scope :value_name, ->(presentation) do
      includes(:option_values).
        where("#{Spree::OptionType.table_name}.presentation = ?", presentation).
        map do |type|
          type.option_values.pluck(:name)
        end.flatten.uniq
    end
  end

  Spree::OptionType.prepend self
end
