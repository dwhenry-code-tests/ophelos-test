class StatementCreator
  attr_reader :user

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
    items = statement.statement_items.group_by(&:item_type)
    income = items.fetch('incomes', []).sum(&:amount)
    expenditure = items.fetch('expenditures', []).sum(&:amount)

    income - expenditure
  end

  def ie_rating
    items = statement.statement_items.group_by(&:item_type)
    income = items.fetch('incomes', []).sum(&:amount)
    expenditure = items.fetch('expenditures', []).sum(&:amount)

    return "D" if income.zero?

    case expenditure / income
    when (0...0.1) then "A"
    when (0.1...0.3) then "B"
    when (0.3...0.5) then "C"
    else "D"
    end
  end
end