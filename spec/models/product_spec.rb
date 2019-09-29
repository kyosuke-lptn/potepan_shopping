require 'rails_helper'

RSpec.describe Spree::Product, type: :model do
  describe "#filter_by_taxon" do
    subject { Spree::Product.filter_by_taxon(taxon) }

    let!(:product) { create(:product, taxons: [taxon]) }
    let!(:other_product) { create(:product, taxons: []) }
    let!(:taxon) { create(:taxon) }

    it { is_expected.to include product }
    it { is_expected.not_to include other_product }
  end

  describe "#filter_by_option_value" do
    subject { Spree::Product.filter_by_option_value(option_value.presentation) }

    let!(:product) { variant.product }
    let!(:variant) { create(:variant, option_values: [option_value]) }
    let!(:option_value) { create(:option_value, presentation: "Color") }
    let!(:other_product) { othre_variant.product }
    let!(:othre_variant) { create(:variant, option_values: [other_option_value]) }
    let!(:other_option_value) { create(:option_value, presentation: "Size") }

    it { is_expected.to include product }
    it { is_expected.not_to include other_product }
  end
end
