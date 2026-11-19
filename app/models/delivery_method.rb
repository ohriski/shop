class DeliveryMethod < ApplicationRecord
  has_many :orders, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }

  validates :name, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
