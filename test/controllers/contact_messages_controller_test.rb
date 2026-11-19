require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  def valid_params(**overrides)
    { name: "Олена", email: "olena@example.com", subject: "Питання", body: "Чи є доставка у Київ?" }.merge(overrides)
  end

  test "guest can open the contact page" do
    get new_contact_message_url
    assert_response :success
  end

  test "saves the message and queues an email" do
    assert_difference("ContactMessage.count", 1) do
      assert_enqueued_emails 1 do
        post contact_messages_url, params: { contact_message: valid_params }
      end
    end
    assert_redirected_to root_url
  end

  test "invalid message is not saved and no email is queued" do
    assert_no_difference("ContactMessage.count") do
      assert_no_enqueued_emails do
        post contact_messages_url, params: { contact_message: valid_params(email: "не-email") }
      end
    end
    assert_response :unprocessable_entity
  end
end
