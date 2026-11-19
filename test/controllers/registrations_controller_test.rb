require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_url
    assert_response :success
  end

  test "should register a new user" do
    assert_difference("User.count") do
      post registration_url, params: { user: { email_address: "new@example.com", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to root_url
  end

  test "should not register with short password" do
    assert_no_difference("User.count") do
      post registration_url, params: { user: { email_address: "short@example.com", password: "123", password_confirmation: "123" } }
    end
    assert_response :unprocessable_entity
  end
end
