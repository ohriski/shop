module Admin
  class OrdersController < BaseController
    def index
      @status = params[:status].presence_in(Order.statuses.keys)
      @orders = Order.includes(:user, :delivery_method).order(created_at: :desc)
      @orders = @orders.where(status: @status) if @status
    end

    def show
      @order = Order.find(params[:id])
    end

    def update
      @order = Order.find(params[:id])

      if @order.change_status!(params.expect(order: [ :status ])[:status])
        redirect_to admin_order_path(@order), notice: "Статус оновлено"
      else
        redirect_to admin_order_path(@order), alert: "Неможливо змінити статус цього замовлення"
      end
    end
  end
end
