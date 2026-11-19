module Admin
  class ContactMessagesController < BaseController
    def index
      @contact_messages = ContactMessage.order(created_at: :desc)
    end

    def show
      @contact_message = ContactMessage.find(params[:id])
    end

    def destroy
      ContactMessage.find(params[:id]).destroy
      redirect_to admin_contact_messages_path, notice: "Повідомлення видалено"
    end
  end
end
