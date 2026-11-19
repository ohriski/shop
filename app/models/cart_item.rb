class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }
  validate :quantity_within_stock

  def subtotal
    product.price * quantity
  end

  private

  def quantity_within_stock
    return unless product && quantity

    if quantity > product.stock
      errors.add(:quantity, "перевищує наявну кількість на складі (#{product.stock})")
    end
  end
end
