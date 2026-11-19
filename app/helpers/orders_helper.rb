module OrdersHelper
  STATUS_BADGES = {
    "pending" => "warning",
    "paid" => "success",
    "shipped" => "info",
    "cancelled" => "secondary"
  }.freeze

  def order_status_badge(order)
    tag.span order.status_label, class: "badge text-bg-#{STATUS_BADGES[order.status]}"
  end
end
