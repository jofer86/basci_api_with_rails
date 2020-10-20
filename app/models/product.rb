class Product < ApplicationRecord
  belongs_to :user
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :title, :user_id, presence: true
end
