class Statement < ApplicationRecord
  belongs_to :user
  has_many :statement_items

  validates :year, presence: true

  def as_json(*)
    super.slice("year", "disposable_income", "ie_rating")
  end
end
