class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy


  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :name, length: { maximum: 100 }, allow_blank: true
validates :phone, length: { maximum: 30 }, allow_blank: true
end
