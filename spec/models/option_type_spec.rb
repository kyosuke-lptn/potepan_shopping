require 'rails_helper'

RSpec.describe Spree::OptionType, type: :model do
  describe "#value_name" do
    subject { Spree::OptionType.value_name(option_type.presentation) }

    let!(:option_type) { create(:option_type, presentation: "Color") }
    let!(:option_value1) { create(:option_value, option_type: option_type, name: "Red") }
    let!(:option_value2) { create(:option_value, option_type: option_type, name: "Blue") }
    let!(:option_value3) { create(:option_value, option_type: option_type, name: "Black") }
    let!(:other_option_value) { create(:option_value, name: "Small") }

    it do
      is_expected.to contain_exactly(option_value1.name, option_value2.name, option_value3.name)
    end
    it { is_expected.not_to contain_exactly other_option_value.name }
  end
end
