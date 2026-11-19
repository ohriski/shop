require "test_helper"

class CancelUnpaidOrdersJobTest < ActiveJob::TestCase
  def place_order(**attrs)
    cart = Cart.create!
    cart.add_product(products(:one), 1)
    order = users(:one).orders.new({ customer_name: "Іван", phone: "123", delivery_method: delivery_methods(:pickup) }.merge(attrs))
    order.place_from(cart)
    order
  end

  test "cancels a stale unpaid card order" do
    order = place_order
    order.update_columns(created_at: 25.hours.ago)

    CancelUnpaidOrdersJob.perform_now
    assert order.reload.cancelled?
  end

  test "returns the goods to stock" do
    order = place_order
    order.update_columns(created_at: 25.hours.ago)

    assert_difference -> { products(:one).reload.stock }, 1 do
      CancelUnpaidOrdersJob.perform_now
    end
  end

  test "keeps fresh, paid and cash on delivery orders" do
    fresh = place_order
    paid = place_order
    paid.pay!
    paid.update_columns(created_at: 25.hours.ago)
    cod = place_order(payment_method: :cash_on_delivery)
    cod.update_columns(created_at: 25.hours.ago)

    CancelUnpaidOrdersJob.perform_now
    assert fresh.reload.pending?
    assert paid.reload.paid?
    assert cod.reload.pending?
  end
end
