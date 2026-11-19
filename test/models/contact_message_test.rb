require "test_helper"

class ContactMessageTest < ActiveSupport::TestCase
  def build_message(**attrs)
    ContactMessage.new({ name: "Олена", email: "olena@example.com", subject: "Питання", body: "Чи є доставка у Київ?" }.merge(attrs))
  end

  test "is valid with correct data" do
    assert build_message.valid?
  end

  test "requires all fields" do
    %i[name email subject body].each do |field|
      assert_not build_message(field => "").valid?, "#{field} має бути обов'язковим"
    end
  end

  test "rejects an invalid email" do
    assert_not build_message(email: "не-email").valid?
  end

  test "normalizes the email" do
    assert_equal "olena@example.com", build_message(email: "  OLENA@Example.com ").email
  end
end
