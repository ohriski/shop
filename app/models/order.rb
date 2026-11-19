class Order < ApplicationRecord
  belongs_to :user
  belongs_to :delivery_method
  has_many :order_items, dependent: :destroy

  enum :status, { pending: 0, paid: 1, shipped: 2, cancelled: 3 }, default: :pending
  enum :payment_method, { card: 0, cash_on_delivery: 1 }, default: :card, prefix: :payment

  STATUS_LABELS = {
    "pending" => "Очікує оплати",
    "paid" => "Оплачено",
    "shipped" => "Відправлено",
    "cancelled" => "Скасовано"
  }.freeze

  PAYMENT_METHOD_LABELS = {
    "card" => "Банківська картка (онлайн)",
    "cash_on_delivery" => "Оплата при отриманні"
  }.freeze

  validates :customer_name, :phone, presence: true
  validates :city, :address, presence: true, if: -> { delivery_method&.requires_address? }
  validates :total_price, :delivery_price, numericality: { greater_than_or_equal_to: 0 }
  validate :delivery_method_available, on: :create

  def status_label
    STATUS_LABELS[status]
  end

  def payment_method_label
    PAYMENT_METHOD_LABELS[payment_method]
  end

  def items_total
    order_items.to_a.sum(&:subtotal)
  end

  # Потребує онлайн-оплати: картка й ще не оплачено
  def payable?
    pending? && payment_card?
  end

  # Імітація платежу. Блокування запису не дає оплатити замовлення двічі.
  def pay!
    with_lock do
      if payable?
        update!(status: :paid, paid_at: Time.current, payment_reference: "TEST-#{SecureRandom.hex(6).upcase}")
        true
      else
        false
      end
    end
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

      self.delivery_price = delivery_method.price
      self.total_price = items_total + delivery_price
      save!
      cart.cart_items.destroy_all
    end

    persisted?
  end

  private

  def delivery_method_available
    errors.add(:delivery_method, "наразі недоступний") if delivery_method && !delivery_method.active?
  end
end
