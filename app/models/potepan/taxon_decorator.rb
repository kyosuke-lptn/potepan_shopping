module Potepan::TaxonDecorator
  def self.prepended(base)
    base.has_attached_file :icon,
                           styles: { mini: '32x32>', normal: '128x128>', large: '360x360#' },
                           default_style: :mini,
                           url: '/spree/taxons/:id/:style/:basename.:extension',
                           path: ':rails_root/public/spree/taxons/:id/:style/:basename.:extension',
                           default_url: '/assets/default_taxon.png'
  end

  Spree::Taxon.prepend self
end
