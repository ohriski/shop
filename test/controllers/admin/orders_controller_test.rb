require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  def sign_in_admin
    admin = users(:one)
    admin.update!(admin: true)
    sign_in_as admin
  end

  def create_order
    cart = Cart.create!
    cart.add_product(products(:one), 1)
    order = users(:two).orders.new(customer_name: "Іван", phone: "123", delivery_method: delivery_methods(:pickup))
    order.place_from(cart)
    order
  end

  test "guest is redirected to login" do
    get admin_orders_url
    assert_redirected_to new_session_url
  end

  test "regular user has no access" do
    users(:two).update!(admin: false)
    sign_in_as users(:two)

    get admin_orders_url
    assert_redirected_to root_url
  end

  test "admin sees the orders list" do
    order = create_order
    sign_in_admin

    get admin_orders_url
    assert_response :success
    assert_select "td", text: "№#{order.id}"
  end

  test "filters orders by status" do
    pending_order = create_order
    paid_order = create_order
    paid_order.change_status!("paid")
    sign_in_admin

    get admin_orders_url(status: "paid")
    assert_select "td", text: "№#{paid_order.id}"
    assert_select "td", text: "№#{pending_order.id}", count: 0
  end

  test "admin sees order details" do
    order = create_order
    sign_in_admin

    get admin_order_url(order)
    assert_response :success
  end

  test "admin changes the status" do
    order = create_order
    sign_in_admin

    patch admin_order_url(order), params: { order: { status: "shipped" } }
    assert_redirected_to admin_order_url(order)
    assert order.reload.shipped?
  end

  test "cancelling returns goods to stock" do
    order = create_order
    sign_in_admin

    assert_difference -> { products(:one).reload.stock }, 1 do
      patch admin_order_url(order), params: { order: { status: "cancelled" } }
    end
    assert order.reload.cancelled?
  end

  test "cancelled order cannot be changed" do
    order = create_order
    order.change_status!("cancelled")
    sign_in_admin

    patch admin_order_url(order), params: { order: { status: "paid" } }
    assert_redirected_to admin_order_url(order)
    assert order.reload.cancelled?
  end

  test "unknown status is ignored" do
    order = create_order
    sign_in_admin

    patch admin_order_url(order), params: { order: { status: "bogus" } }
    assert_redirected_to admin_order_url(order)
    assert order.reload.pending?
  end
end
