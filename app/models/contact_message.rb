class ContactMessage < ApplicationRecord
  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true, length: { maximum: 150 }
  validates :body, presence: true, length: { maximum: 3000 }
end
