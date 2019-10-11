module ApplicationHelper
  def full_title(page_title: "")
    base_title = "BIGBAG Store"
    if page_title.blank?
      base_title
    else
      "#{page_title} - #{base_title}"
    end
  end

  def select_light_section(header_title)
    if header_title == "CART"
      return render( # rubocop: disable Style/RedundantReturn
        'potepan/orders/light_section', header_title: header_title
      )
    else
      return render( # rubocop: disable Style/RedundantReturn
        'layouts/light_section', header_title: header_title
      )
    end
  end
end
