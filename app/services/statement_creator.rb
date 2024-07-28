class StatementCreator
  attr_reader :user
  delegate :errors, to: :statement

  def initialize(user)
    @user = user
  end

  def call(params)
    %w[incomes expenditures].each do |item_type|
      params[item_type].each do |item|
        statement.statement_items.build(item_type:, **item)
      end
    end

    return false unless statement.valid?

    statement.disposable_income = disposable_income
    statement.ie_rating = ie_rating

    statement.save
  end

  def statement
    @statement ||= Statement.new(user: user, year: Date.today.year)
  end

  private

  def disposable_income
    [
      BigDecimal("0.0"),
      income_and_expenditure[:income] - income_and_expenditure[:expenditure]
    ].max
  end

  def ie_rating
    return "D" if income_and_expenditure[:income].zero?

    case income_and_expenditure[:expenditure] / income_and_expenditure[:income]
    when (0...0.1) then "A"
    when (0.1...0.3) then "B"
    when (0.3...0.5) then "C"
    else "D"
    end
  end

  def income_and_expenditure
    @income_and_expenditure ||=
      begin
        items = statement.statement_items.group_by(&:item_type)
        {
          income: items.fetch('incomes', []).sum(&:amount),
          expenditure: items.fetch('expenditures', []).sum(&:amount)
        }
      end
  end
end
