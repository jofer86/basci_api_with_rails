class User < ApplicationRecord
  has_many :products, dependent: :destroy
  has_secure_password
  validates :email, uniqueness: true
  validates_format_of :email, with: /@/
  validates :password_digest, presence: true
end




def check_amount
  self.save if self.balance  >= MIN_AMOUNT
end
