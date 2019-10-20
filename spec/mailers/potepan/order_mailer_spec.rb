require "rails_helper"

RSpec.describe Potepan::OrderMailer, type: :mailer do
  let(:order) { OrderWalkthrough_up_to(:complete) }
  let(:text_body) do
    part = mail.body.parts.detect { |portion| portion.content_type == 'text/plain; charset=UTF-8' }
    part.body.raw_source
  end
  let(:html_body) do
    part = mail.body.parts.detect { |portion| portion.content_type == 'text/html; charset=UTF-8' }
    part.body.raw_source
  end

  describe '#confirm_email' do
    let(:mail) { Potepan::OrderMailer.confirm_email(order) }

    it "想定どおりのメールが生成されている" do
      aggregate_failures do
        expect(mail.subject).to eq('ご注文の確認')
        expect(mail.to).to eq([order.email])
        expect(mail.from).to eq([@store.mail_from_address])

        expect(text_body).to match('ご注文内容')
        expect(text_body).to match(order.ship_address.zipcode)
        expect(html_body).to match('ご注文内容')
        expect(html_body).to match(order.ship_address.zipcode)
        order.line_items.each do |item|
          expect(text_body).to match(item.name)
          expect(html_body).to match(item.name)
        end
      end
    end
  end
end
