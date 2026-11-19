require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @cart = Cart.create!
  end

  def build_order
    @user.orders.new(customer_name: "Іван Петренко", phone: "+380501234567")
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
    order = @user.orders.new

    assert_not order.place_from(@cart)
    assert order.errors[:customer_name].any?
    assert order.errors[:phone].any?
  end
end
