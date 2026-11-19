require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @cart = Cart.create!
  end

  def build_order(delivery_method: delivery_methods(:pickup), **attrs)
    @user.orders.new({ customer_name: "Іван Петренко", phone: "+380501234567", delivery_method: delivery_method }.merge(attrs))
  end

  test "places an order from the cart" do
    @cart.add_product(products(:one), 2) # 2 x 10.50
    order = build_order

    assert_difference [ "Order.count", "OrderItem.count" ], 1 do
      assert order.place_from(@cart)
    end
    assert_equal 21, order.total_price
    assert_equal "pending", order.status
  end

  test "decreases stock and empties the cart" do
    @cart.add_product(products(:one), 2)

    assert_difference -> { products(:one).reload.stock }, -2 do
      build_order.place_from(@cart)
    end
    assert_equal 0, @cart.cart_items.count
  end

  test "keeps the price at the time of purchase" do
    @cart.add_product(products(:one), 1)
    order = build_order
    order.place_from(@cart)

    products(:one).update!(price: 99)
    assert_equal 10.5, order.order_items.first.reload.unit_price
  end

  test "fails when stock became too low" do
    @cart.add_product(products(:one), 3)
    products(:one).update!(stock: 1)
    order = build_order

    assert_no_difference [ "Order.count", "OrderItem.count" ] do
      assert_not order.place_from(@cart)
    end
    assert order.errors[:base].any?
    assert_equal 1, products(:one).reload.stock
    assert_equal 1, @cart.cart_items.count
  end

  test "requires name and phone" do
    @cart.add_product(products(:one), 1)
    order = build_order(customer_name: "", phone: "")

    assert_not order.place_from(@cart)
    assert order.errors[:customer_name].any?
    assert order.errors[:phone].any?
  end

  test "courier delivery requires city and address" do
    @cart.add_product(products(:one), 1)
    order = build_order(delivery_method: delivery_methods(:courier))

    assert_not order.place_from(@cart)
    assert order.errors[:city].any?
    assert order.errors[:address].any?
  end

  test "pickup does not require an address" do
    @cart.add_product(products(:one), 1)
    assert build_order.place_from(@cart)
  end

  test "adds the delivery price to the total" do
    @cart.add_product(products(:one), 2) # 21
    order = build_order(delivery_method: delivery_methods(:courier), city: "Львів", address: "вул. Зелена, 1")

    assert order.place_from(@cart)
    assert_equal 100, order.delivery_price
    assert_equal 121, order.total_price
  end

  test "keeps the delivery price at the time of purchase" do
    @cart.add_product(products(:one), 1)
    order = build_order(delivery_method: delivery_methods(:courier), city: "Львів", address: "вул. Зелена, 1")
    order.place_from(@cart)

    delivery_methods(:courier).update!(price: 500)
    assert_equal 100, order.reload.delivery_price
  end

  test "inactive delivery method is rejected" do
    delivery_methods(:courier).update!(active: false)
    @cart.add_product(products(:one), 1)
    order = build_order(delivery_method: delivery_methods(:courier), city: "Львів", address: "вул. Зелена, 1")

    assert_not order.place_from(@cart)
    assert order.errors[:delivery_method].any?
  end

  test "card order is payable and cash on delivery is not" do
    @cart.add_product(products(:one), 1)
    card = build_order
    card.place_from(@cart)
    assert card.payable?

    other_cart = Cart.create!
    other_cart.add_product(products(:two), 1)
    cod = build_order(payment_method: :cash_on_delivery)
    cod.place_from(other_cart)
    assert_not cod.payable?
  end

  test "pay! marks the order as paid" do
    @cart.add_product(products(:one), 1)
    order = build_order
    order.place_from(@cart)

    assert order.pay!
    assert order.paid?
    assert_not_nil order.paid_at
    assert order.payment_reference.start_with?("TEST-")
  end

  test "cannot pay twice" do
    @cart.add_product(products(:one), 1)
    order = build_order
    order.place_from(@cart)

    assert order.pay!
    assert_not order.pay!
  end

  test "cash on delivery order cannot be paid online" do
    @cart.add_product(products(:one), 1)
    order = build_order(payment_method: :cash_on_delivery)
    order.place_from(@cart)

    assert_not order.pay!
    assert order.pending?
  end
end
