module CurrentCart
  extend ActiveSupport::Concern

  included do
    helper_method :cart_quantity
  end

  private

  # Знаходить кошик за cookie, але нічого не створює
  def find_cart
    return @current_cart if @current_cart

    cart_id = cookies.signed[:cart_id]
    @current_cart = Cart.find_by(id: cart_id) if cart_id
  end

  # Повертає кошик, а за потреби створює новий
  def current_cart
    find_cart || create_cart
  end

  def create_cart
    @current_cart = Cart.create!
    cookies.signed[:cart_id] = { value: @current_cart.id, expires: 30.days.from_now, httponly: true }
    @current_cart
  end

  # Для лічильника в меню
  def cart_quantity
    find_cart&.total_quantity || 0
  end
end
