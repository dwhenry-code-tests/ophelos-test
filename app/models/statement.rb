class Statement < ApplicationRecord
  belongs_to :user
  has_many :statement_items

  validates :year, presence: true, uniqueness: { scope: :user }

  def as_json(*)
    {
      "year" => year,
      "disposable_income" => disposable_income.to_f,
      "ie_rating" => ie_rating
    }
  end
end
