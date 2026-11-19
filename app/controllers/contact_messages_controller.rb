class ContactMessagesController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 10.minutes, only: :create,
             with: -> { redirect_to new_contact_message_path, alert: "Забагато спроб. Спробуйте пізніше" }

  def new
    @contact_message = ContactMessage.new(email: (Current.user.email_address if authenticated?))
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)

    if @contact_message.save
      ContactMailer.new_message(@contact_message).deliver_later
      redirect_to root_path, notice: "Дякуємо! Ваше повідомлення надіслано"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_message_params
    params.expect(contact_message: %i[name email subject body])
  end
end
