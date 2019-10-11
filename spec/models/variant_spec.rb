require 'rails_helper'

RSpec.describe Spree::Variant, type: :model do
  let!(:variant) { create(:variant) }

  it "returns array of the number of total_on_hand" do
    variant.stock_items.first.set_count_on_hand(5)
    expect(variant.selectable_quantity).to eq [*1..5]
  end

  it "returns array([1..10])" do
    variant.stock_items.first.set_count_on_hand(20)
    expect(variant.selectable_quantity).to eq [*1..10]
  end
end
