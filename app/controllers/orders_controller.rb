class OrdersController < ApplicationController
  before_action :load_cart, only: %i[new create]

  def new
    @order = Current.user.orders.new
  end

  def create
    @order = Current.user.orders.new(order_params)

    if @order.place_from(@cart)
      redirect_to @order, notice: "Замовлення №#{@order.id} оформлено"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Current.user.orders.find(params[:id])
  end

  private

  def order_params
    params.expect(order: %i[customer_name phone])
  end

  def load_cart
    @cart = find_cart

    if @cart.nil? || @cart.cart_items.empty?
      redirect_to cart_path, alert: "Кошик порожній"
    else
      @items = @cart.cart_items.includes(:product)
    end
  end
end
