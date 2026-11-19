class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image

  validates :name, presence: true, uniqueness: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :acceptable_image

  private

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
