require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  def create_order(user)
    cart = Cart.create!
    cart.add_product(products(:one), 1)
    order = user.orders.new(customer_name: "Іван", phone: "123", delivery_method: delivery_methods(:pickup))
    order.place_from(cart)
    order
  end

  test "guest is redirected to login" do
    get profile_url
    assert_redirected_to new_session_url
  end

  test "shows own orders" do
    sign_in_as @user
    order = create_order(@user)

    get profile_url
    assert_response :success
    assert_match "№#{order.id}", response.body
  end

  test "does not show other users' orders" do
    sign_in_as @user
    other = create_order(users(:two))

    get profile_url
    assert_response :success
    assert_no_match "№#{other.id}", response.body
  end

  test "updates name and phone without touching the password" do
    sign_in_as @user

    patch profile_url, params: { user: { name: "Іван Петренко", phone: "+380501234567", password: "", password_confirmation: "" } }
    assert_redirected_to profile_url
    @user.reload
    assert_equal "Іван Петренко", @user.name
    assert_equal "+380501234567", @user.phone
    assert @user.authenticate("password")
  end

  test "changing email requires the current password" do
    sign_in_as @user
    old_email = @user.email_address

    patch profile_url, params: { user: { email_address: "new@example.com" } }
    assert_response :unprocessable_entity
    assert_equal old_email, @user.reload.email_address
  end

  test "changes email with the correct current password" do
    sign_in_as @user

    patch profile_url, params: { user: { email_address: "new@example.com", current_password: "password" } }
    assert_redirected_to profile_url
    assert_equal "new@example.com", @user.reload.email_address
  end

  test "changes the password with the correct current password" do
    sign_in_as @user

    patch profile_url, params: { user: { current_password: "password", password: "newpassword123", password_confirmation: "newpassword123" } }
    assert_redirected_to profile_url
    assert @user.reload.authenticate("newpassword123")
  end

  test "does not change the password with a wrong current password" do
    sign_in_as @user

    patch profile_url, params: { user: { current_password: "wrong", password: "newpassword123", password_confirmation: "newpassword123" } }
    assert_response :unprocessable_entity
    assert @user.reload.authenticate("password")
  end

  test "changing the password ends other sessions" do
    sign_in_as @user
    @user.sessions.create!(ip_address: "1.1.1.1", user_agent: "other device")

    assert_difference -> { @user.sessions.count }, -1 do
      patch profile_url, params: { user: { current_password: "password", password: "newpassword123", password_confirmation: "newpassword123" } }
    end
  end
end
