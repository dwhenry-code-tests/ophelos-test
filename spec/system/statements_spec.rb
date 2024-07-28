require "rails_helper"

RSpec.describe "Statements" do
  let(:user) { User.create(email: "test@test.com") }
  let(:statement) { { incomes:, expenditures: } }
  let(:incomes) { [{ name: 'salary', amount: 70_000.0 }] }
  let(:expenditures) { [{ name: 'rent', amount: 15_600.0 }] }

  context "when request is missing an authentication token" do
    it "returns a 403" do
      post '/v1/statements', params: { statement: statement, token: '' }

      expect(response.status).to eq(403)
    end
  end

  context "when token is expired" do
    it "returns a 403" do
      token = travel_to(10.minutes.ago) { Security::Jwt::Generator.new(user).generate_jwt }
      post '/v1/statements', params: { statement: statement, token: token }

      expect(response.status).to eq(403)
    end
  end

  context "when valid token" do
    it "creates a new statement for the current year" do
      token = Security::Jwt::Generator.new(user).generate_jwt
      expect { post '/v1/statements', params: { statement: statement, token: token } }.to change(Statement, :count).by(1)

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to match(
        "statement" => {
          "year" => Date.today.year,
          "disposable_income" => "54400.0",
          "ie_rating" => "B"
        },
        "token" => an_instance_of(String)
      )
    end
  end
end
