module Potepan
  module CheckoutHelper
    def select_render(state)
      if state == "address"
        return render('potepan/checkout/address') # rubocop: disable Style/RedundantReturn
      elsif state == "payment"
        return render('potepan/checkout/payment') # rubocop: disable Style/RedundantReturn
      elsif state == "confirm"
        return render('potepan/checkout/confirm') # rubocop: disable Style/RedundantReturn
      end
    end
  end
end
