require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end
  test "new users are not admins by default" do
  assert_not User.new.admin?
end

test "requires a password of at least 8 characters" do
  user = User.new(email_address: "short@example.com", password: "123", password_confirmation: "123")
  assert_not user.valid?
end
end
