class User < ApplicationRecord
  has_many :statements
  validates :email, presence: true, uniqueness: true
end
