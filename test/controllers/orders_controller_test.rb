require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  def add_to_cart(product, times = 1)
    times.times { post cart_items_url, params: { product_id: product.id } }
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

  test "places an order" do
    sign_in_as users(:one)
    add_to_cart(products(:one), 2)

    assert_difference("Order.count", 1) do
      post orders_url, params: { order: { customer_name: "Іван Петренко", phone: "+380501234567" } }
    end
    assert_redirected_to order_url(Order.last)
    assert_equal 0, CartItem.count
  end

  test "does not place an order without a phone" do
    sign_in_as users(:one)
    add_to_cart(products(:one))

    assert_no_difference("Order.count") do
      post orders_url, params: { order: { customer_name: "Іван", phone: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "cannot see someone else's order" do
    sign_in_as users(:one)
    other = users(:two).orders.create!(customer_name: "Інший", phone: "123")
    get order_url(other)
    assert_response :not_found
  end
end
