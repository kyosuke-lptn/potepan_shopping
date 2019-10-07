module ApplicationHelper
  def full_title(page_title: "")
    base_title = "BIGBAG Store"
    if page_title.blank?
      base_title
    else
      "#{page_title} - #{base_title}"
    end
  end

  def select_light_section(title_name)
    if title_name == "CART"
      return render('potepan/orders/light_section') # rubocop: disable Style/RedundantReturn
    else
      return render('layouts/light_section') # rubocop: disable Style/RedundantReturn
    end
  end
end
