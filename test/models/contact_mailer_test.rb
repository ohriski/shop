require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "new_message" do
    message = ContactMessage.create!(name: "Олена", email: "olena@example.com", subject: "Питання", body: "Чи є доставка у Київ?")
    mail = ContactMailer.new_message(message)

    assert_equal [ "shop@example.com" ], mail.to
    assert_equal [ "olena@example.com" ], mail.reply_to
    assert_match "Питання", mail.subject
    assert_includes mail.text_part.body.decoded.dup.force_encoding("UTF-8"), "Чи є доставка у Київ?"
  end
end
