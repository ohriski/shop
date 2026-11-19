module ApplicationHelper
  def money(amount)
    number_to_currency(amount, unit: "₴", format: "%n %u")
  end
end
