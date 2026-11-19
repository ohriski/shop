require "test_helper"

class Admin::ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @message = ContactMessage.create!(name: "Олена", email: "olena@example.com", subject: "Питання про доставку", body: "Чи є доставка у Київ?")
  end

  def sign_in_admin
    admin = users(:one)
    admin.update!(admin: true)
    sign_in_as admin
  end

  test "regular user has no access" do
    users(:two).update!(admin: false)
    sign_in_as users(:two)

    get admin_contact_messages_url
    assert_redirected_to root_url
  end

  test "admin sees the list" do
    sign_in_admin
    get admin_contact_messages_url
    assert_response :success
    assert_match "Питання про доставку", response.body
  end

  test "admin opens a message" do
    sign_in_admin
    get admin_contact_message_url(@message)
    assert_response :success
    assert_match "Чи є доставка у Київ?", response.body
  end

  test "admin deletes a message" do
    sign_in_admin

    assert_difference("ContactMessage.count", -1) do
      delete admin_contact_message_url(@message)
    end
    assert_redirected_to admin_contact_messages_url
  end
end
