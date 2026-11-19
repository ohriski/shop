require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  def add_to_cart(product, times = 1)
    times.times { post cart_items_url, params: { product_id: product.id } }
  end

  def valid_order_params(**overrides)
    {
      customer_name: "Іван Петренко",
      phone: "+380501234567",
      delivery_method_id: delivery_methods(:pickup).id
    }.merge(overrides)
  end

  test "guest is redirected to login" do
    add_to_cart(products(:one))
    get new_order_url
    assert_redirected_to new_session_url
  end

  test "redirects to cart when it is empty" do
    sign_in_as users(:one)
    get new_order_url
    assert_redirected_to cart_url
  end

  test "shows the checkout page" do
    sign_in_as users(:one)
    add_to_cart(products(:one))
    get new_order_url
    assert_response :success
  end

  test "places an order and redirects to payment" do
    sign_in_as users(:one)
    add_to_cart(products(:one), 2)

    assert_difference("Order.count", 1) do
      post orders_url, params: { order: valid_order_params }
    end
    assert_redirected_to new_order_payment_url(Order.last)
    assert_equal 0, CartItem.count
  end

  test "cash on delivery order goes straight to the order page" do
    sign_in_as users(:one)
    add_to_cart(products(:one))

    post orders_url, params: { order: valid_order_params(payment_method: "cash_on_delivery") }
    assert_redirected_to order_url(Order.last)
    assert Order.last.pending?
  end

  test "does not place an order without a phone" do
    sign_in_as users(:one)
    add_to_cart(products(:one))

    assert_no_difference("Order.count") do
      post orders_url, params: { order: valid_order_params(phone: "") }
    end
    assert_response :unprocessable_entity
  end

  test "courier order requires an address" do
    sign_in_as users(:one)
    add_to_cart(products(:one))

    assert_no_difference("Order.count") do
      post orders_url, params: { order: valid_order_params(delivery_method_id: delivery_methods(:courier).id) }
    end
    assert_response :unprocessable_entity
  end

  test "places an order with courier delivery" do
    sign_in_as users(:one)
    add_to_cart(products(:one))

    post orders_url, params: { order: valid_order_params(
      delivery_method_id: delivery_methods(:courier).id,
      city: "Львів", address: "вул. Зелена, 1"
    ) }
    assert_redirected_to new_order_payment_url(Order.last)
    assert_equal 100, Order.last.delivery_price
  end

  test "cannot see someone else's order" do
    sign_in_as users(:one)
    other = users(:two).orders.create!(customer_name: "Інший", phone: "123", delivery_method: delivery_methods(:pickup))

    get order_url(other)
    assert_response :not_found
  end
end
