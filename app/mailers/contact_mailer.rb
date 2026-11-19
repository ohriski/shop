class ContactMailer < ApplicationMailer
  def new_message(contact_message)
    @contact_message = contact_message

    mail(
      to: ENV.fetch("CONTACT_EMAIL", "shop@example.com"),
      reply_to: contact_message.email,
      subject: "Нове повідомлення: #{contact_message.subject}"
    )
  end
end
