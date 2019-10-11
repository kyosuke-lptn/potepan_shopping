require 'rails_helper'

RSpec.describe Spree::OptionType, type: :model do
  describe "#value_name" do
    subject { Spree::OptionType.value_name(option_type.presentation) }

    let!(:option_type) do
      create(:option_type, presentation: "Color")
    end
    let!(:option_value1) do
      create(:option_value, option_type: option_type, name: "Red", presentation: "Red")
    end
    let!(:option_value2) do
      create(:option_value, option_type: option_type, name: "Blue", presentation: "Blue")
    end
    let!(:option_value3) do
      create(:option_value, option_type: option_type, name: "Black", presentation: "Black")
    end
    let!(:other_option_value) { create(:option_value, name: "Small", presentation: "S") }

    it do
      is_expected.to contain_exactly(
        option_value1.presentation,
        option_value2.presentation,
        option_value3.presentation
      )
    end
    it { is_expected.not_to contain_exactly other_option_value.presentation }
  end
end
