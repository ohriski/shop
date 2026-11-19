class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy

def average_rating
  reviews.average(:rating)&.round(1) || 0
end

  validates :name, presence: true, uniqueness: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :acceptable_image

# Зміна статусу адміністратором. Скасування повертає товари на склад,
# скасоване замовлення змінити не можна, повернення в "pending" заборонене.
def change_status!(new_status)
  new_status = new_status.to_s
  return false unless self.class.statuses.key?(new_status) && new_status != "pending"

  with_lock do
    if cancelled? || status == new_status
      false
    else
      restock! if new_status == "cancelled"

      attrs = { status: new_status }
      attrs[:paid_at] = paid_at || Time.current if new_status == "paid"
      update!(attrs)
      true
    end
  end
end

  private

def restock!
  order_items.includes(:product).each do |item|
    item.product.increment!(:stock, item.quantity)
  end
end

  def acceptable_image
    return unless image.attached?

    unless image.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:image, "має бути у форматі JPG, PNG або WEBP")
    end

    if image.byte_size > 5.megabytes
      errors.add(:image, "завелике (максимум 5 МБ)")
    end
  end
end
