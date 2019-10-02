require 'rails_helper'

RSpec.describe ProductSearchForm, type: :model do
  describe "#search" do
    let(:taxon) { create(:taxon) }

    context "taxonのみで絞った場合" do
      let!(:product) { create(:product, taxons: [taxon]) }
      it "絞ったtaxonをもつ商品のみ表示される" do
        form = ProductSearchForm.new(taxon: taxon)
        aggregate_failures do
          expect(form.search).to contain_exactly product
        end
      end
    end

    context "taxonとcolorで絞った場合" do
      let!(:color_product) { create(:product, taxons: [taxon], variants: [variant]) }
      let(:variant) { create(:variant, option_values: [option_value]) }
      let(:option_value) { create(:option_value, name: "Red", presentation: "Red") }

      it "絞ったtaxonをもつ商品のみ表示される" do
        form = ProductSearchForm.new(taxon: taxon, color: "Red")
        aggregate_failures do
          expect(form.search).to contain_exactly color_product
        end
      end
    end
  end
end
