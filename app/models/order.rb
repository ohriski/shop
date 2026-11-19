class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  enum :status, { pending: 0, paid: 1, shipped: 2, cancelled: 3 }, default: :pending

  STATUS_LABELS = {
    "pending" => "Очікує оплати",
    "paid" => "Оплачено",
    "shipped" => "Відправлено",
    "cancelled" => "Скасовано"
  }.freeze

  validates :customer_name, :phone, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  def status_label
    STATUS_LABELS[status]
  end

  # Створює замовлення з кошика: перевіряє склад, списує залишки, очищає кошик.
  # Усе в одній транзакції: або виконується повністю, або нічого.
  def place_from(cart)
    return false unless valid?

    transaction do
      cart.cart_items.includes(:product).each do |cart_item|
        product = cart_item.product
        product.lock!

        if cart_item.quantity > product.stock
          errors.add(:base, "«#{product.name}»: на складі лише #{product.stock} шт.")
          raise ActiveRecord::Rollback
        end

        product.decrement!(:stock, cart_item.quantity)
        order_items.build(product: product, quantity: cart_item.quantity, unit_price: product.price)
      end

      self.total_price = order_items.to_a.sum { |item| item.unit_price * item.quantity }
      save!
      cart.cart_items.destroy_all
    end

    persisted?
  end
end
