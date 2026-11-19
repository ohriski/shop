class PaymentsController < ApplicationController
  before_action :set_order
  before_action :ensure_payable

  def new
  end

  def create
    @order.pay!
    redirect_to @order, notice: "Оплата пройшла успішно"
  end

  private

  def set_order
    @order = Current.user.orders.find(params[:order_id])
  end

  def ensure_payable
    return if @order.payable?

    redirect_to @order, alert: "Це замовлення не потребує оплати"
  end
end
