class StatementItem < ApplicationRecord
  belongs_to :statement

  validates :name, presence: true
  validates :amount, presence: true
end
