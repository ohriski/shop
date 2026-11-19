require "test_helper"

class Admin::DeliveryMethodsControllerTest < ActionDispatch::IntegrationTest
  def sign_in_admin
    admin = users(:one)
    admin.update!(admin: true)
    sign_in_as admin
  end

  test "regular user has no access" do
    users(:two).update!(admin: false)
    sign_in_as users(:two)

    get admin_delivery_methods_url
    assert_redirected_to root_url
  end

  test "admin sees the list" do
    sign_in_admin
    get admin_delivery_methods_url
    assert_response :success
    assert_match "Самовивіз", response.body
  end

  test "admin creates a delivery method" do
    sign_in_admin

    assert_difference("DeliveryMethod.count", 1) do
      post admin_delivery_methods_url, params: { delivery_method: { name: "Укрпошта", price: 45, requires_address: true, active: true } }
    end
    assert_redirected_to admin_delivery_methods_url
  end

  test "invalid delivery method is not created" do
    sign_in_admin

    assert_no_difference("DeliveryMethod.count") do
      post admin_delivery_methods_url, params: { delivery_method: { name: "", price: 45 } }
    end
    assert_response :unprocessable_entity
  end

  test "admin updates a delivery method" do
    sign_in_admin
    method = delivery_methods(:courier)

    patch admin_delivery_method_url(method), params: { delivery_method: { price: 80, active: false } }
    assert_redirected_to admin_delivery_methods_url
    method.reload
    assert_equal 80, method.price
    assert_not method.active?
  end

  test "admin deletes an unused delivery method" do
    sign_in_admin
    method = DeliveryMethod.create!(name: "Тимчасова", price: 10)

    assert_difference("DeliveryMethod.count", -1) do
      delete admin_delivery_method_url(method)
    end
  end

  test "cannot delete a delivery method used in orders" do
    cart = Cart.create!
    cart.add_product(products(:one), 1)
    users(:two).orders.new(customer_name: "Іван", phone: "123", delivery_method: delivery_methods(:pickup)).place_from(cart)
    sign_in_admin

    assert_no_difference("DeliveryMethod.count") do
      delete admin_delivery_method_url(delivery_methods(:pickup))
    end
    assert_redirected_to admin_delivery_methods_url
  end
end
