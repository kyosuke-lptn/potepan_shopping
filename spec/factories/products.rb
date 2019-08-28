require 'spree/testing_support/factories'

FactoryBot.define do
  factory :product_show, class: 'Spree::Product' do
    sequence(:name) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }
    description { "As seen on TV!" }
    price { 19.99 }
    cost_price { 17.00 }
    sku { generate(:sku) }
    available_on { 1.year.ago }
    deleted_at { nil }
    shipping_category { |r| Spree::ShippingCategory.first || r.association(:shipping_category) }

    trait :with_taxons_and_images do
      after :create do |product_show|
        taxonomy = create(:taxonomy)
        root_taxon = taxonomy.root
        parent_taxon = create(:taxon,
                              name: 'Parent',
                              taxonomy_id: taxonomy.id,
                              parent: root_taxon)
        child_taxon = create(:taxon,
                             name: 'Parent',
                             taxonomy_id: taxonomy.id,
                             parent: parent_taxon)
        [parent_taxon, child_taxon].each { |t| product_show.taxons << t }
        image = File.open(File.expand_path('../fixtures/thinking-cat.jpg', __dir__))
        product_show.images.create!(attachment: image)
      end
    end
  end
end
