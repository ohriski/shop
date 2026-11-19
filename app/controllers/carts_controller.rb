class CartsController < ApplicationController
  allow_unauthenticated_access

  def show
    @cart = find_cart || Cart.new
    @items = @cart.cart_items.includes(product: { image_attachment: :blob })
  end
end
