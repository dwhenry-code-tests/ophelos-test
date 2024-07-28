require "rails_helper"

RSpec.describe StatementCreator do
  let(:user) { User.create(email: 'test@test.com') }
  let(:creator) { described_class.new(user) }
  let(:params) { { "incomes" => incomes, "expenditures" => expenditures} }
  let(:incomes) { [{"name" => 'salary', "amount" => 100_000}] }
  let(:expenditures) { [{"name" =>'rent', "amount" => 17_000}] }
  let(:statement) do
    creator.call(params)
    creator.statement
  end

  context "when no income items" do
    let(:incomes) { [] }

    it "create statement with a i&e rating of D" do
      expect(statement).to have_attributes(
        disposable_income: BigDecimal("0"),
        ie_rating: "D"
      )
    end
  end

  context "when invalue statement_items" do
    let(:incomes) { [{"name" => 'salary', "amount" => nil}] }

    it "does not create a statement" do
      expect {
        expect(creator.call(params)).to be_falsey
      }.not_to change(Statement, :count)
    end
  end
end