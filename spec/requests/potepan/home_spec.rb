require 'rails_helper'

RSpec.describe "Potepan::Home", type: :request do
  describe "GET /potepan" do
    let!(:new_product) { create(:product, available_on: Time.zone.now) }
    let!(:old_product) { create(:product, available_on: 1.year.ago) }
    let!(:hot_taxon) do
      create(:taxon,
             meta_keywords: "popularity",
             icon: File.new("#{Rails.root}/spec/files/attachment.jpg"))
    end
    let!(:no_hot_taxon) { create(:taxon, name: "clothing", meta_keywords: nil) }

    it "正常に応答する" do
      get potepan_root_path
      expect(response).to have_http_status(200)
    end

    it "人気カテゴリーのみが表示されている" do
      get potepan_root_path
      aggregate_failures do
        expect(response.body).to include hot_taxon.name
        expect(response.body).not_to include no_hot_taxon.name
      end
    end

    it "人気カテゴリーのアイコン画像が表示される" do
      get potepan_root_path
      expect(response.body).to include "attachment.jpg"
    end

    it "新着の商品のみが表示されている" do
      get potepan_root_path
      aggregate_failures do
        expect(response.body).to include new_product.name
        expect(response.body).not_to include old_product.name
      end
    end
  end
end
