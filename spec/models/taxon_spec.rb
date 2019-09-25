require 'rails_helper'

RSpec.describe Spree::Taxon, type: :model do
  it "is valid with file" do
    taxon = FactoryBot.build(:taxon, icon: File.new("#{Rails.root}/spec/files/attachment.jpg"))
    expect(taxon).to be_valid
  end
end
