include Rails.application.routes.url_helpers

module Potepan
  class OrderMailer < ApplicationMailer
    def confirm_email(order)
      @order = order
      @store = @order.store

      mail(
        to: @order.email,
        from: @store.mail_from_address,
        subject: "ご注文の確認"
      )
    end
  end
end
