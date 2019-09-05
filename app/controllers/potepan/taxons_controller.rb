class Potepan::TaxonsController < Spree::TaxonsController
  append_before_action :load_taxonomy, only: [:show]

  private

  def load_taxonomy
    @taxon_root = @taxon.root.children
  end
end
