require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @order = create_order(@user)
  end

  def create_order(user, **attrs)
    cart = Cart.create!
    cart.add_product(products(:one), 1)
    order = user.orders.new({ customer_name: "Іван", phone: "123", delivery_method: delivery_methods(:pickup) }.merge(attrs))
    order.place_from(cart)
    order
  end

  test "guest is redirected to login" do
    get new_order_payment_url(@order)
    assert_redirected_to new_session_url
  end

  test "shows the payment page" do
    sign_in_as @user
    get new_order_payment_url(@order)
    assert_response :success
  end

  test "pays the order" do
    sign_in_as @user
    post order_payment_url(@order)
    assert_redirected_to order_url(@order)
    assert @order.reload.paid?
  end

  test "cannot pay twice" do
    sign_in_as @user
    post order_payment_url(@order)
    paid_at = @order.reload.paid_at

    post order_payment_url(@order)
    assert_redirected_to order_url(@order)
    assert_equal paid_at, @order.reload.paid_at
  end

  test "cash on delivery order has no payment page" do
    cod = create_order(@user, payment_method: :cash_on_delivery)
    sign_in_as @user
    get new_order_payment_url(cod)
    assert_redirected_to order_url(cod)
  end

  test "cannot pay someone else's order" do
    sign_in_as users(:two)
    post order_payment_url(@order)
    assert_response :not_found
    assert @order.reload.pending?
  end
end
