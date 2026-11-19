class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def add_product(product, quantity = 1)
    item = cart_items.find_or_initialize_by(product: product)
    item.quantity = item.new_record? ? quantity : item.quantity + quantity
    item.save
    item
  end

  def total_quantity
    cart_items.sum(:quantity)
  end

  def total_price
    cart_items.includes(:product).to_a.sum(&:subtotal)
  end
end
