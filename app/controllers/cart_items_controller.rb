class CartItemsController < ApplicationController
  allow_unauthenticated_access

  def create
    product = Product.find(params.expect(:product_id))
    item = current_cart.add_product(product, 1)

    if item.errors.empty?
      redirect_back_or_to products_path
    else
      redirect_back_or_to products_path, alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    item = current_cart.cart_items.find(params[:id])

    if item.update(params.expect(cart_item: [ :quantity ]))
      redirect_to cart_path
    else
      redirect_to cart_path, alert: item.errors.full_messages.to_sentence
    end
  end

  def destroy
    item = current_cart.cart_items.find(params[:id])
    item.destroy
    redirect_to cart_path, notice: "Товар видалено з кошика"
  end
end
