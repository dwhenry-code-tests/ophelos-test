require "rails_helper"

RSpec.describe "Statements" do
  let(:token) { Security::Jwt::Generator.new(user).generate_jwt }
  let(:user) { User.create(email: "test@test.com") }
  let(:statement_params) { { "incomes" => incomes, "expenditures" => expenditures } }
  let(:incomes) { [{ name: 'salary', amount: 70_000.0 }] }
  let(:expenditures) { [{ name: 'rent', amount: 15_600.0 }] }

  context "when request is missing an authentication token" do
    it "returns a 403" do
      post '/v1/statements', params: { statement: statement_params, token: '' }

      expect(response.status).to eq(403)
    end
  end

  context "when token is expired" do
    it "returns a 403" do
      token = travel_to(10.minutes.ago) { Security::Jwt::Generator.new(user).generate_jwt }
      post '/v1/statements', params: { statement: statement_params, token: token }

      expect(response.status).to eq(403)
    end
  end

  context "when valid token" do
    it "creates a new statement for the current year" do
      expect {
        post '/v1/statements', params: { statement: statement_params, token: token }
      }.to change(Statement, :count).by(1)

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to match(
        "statement" => {
          "year" => Date.today.year,
          "disposable_income" => 54400.0,
          "ie_rating" => "B"
        },
        "token" => an_instance_of(String)
      )
    end

    context "when invalid data" do
      let(:incomes) { [{ name: 'salary', amount: nil }] }

      it "409 with a description of the error" do
        expect {
          post '/v1/statements', params: { statement: statement_params, token: token }
        }.not_to change(Statement, :count)

        expect(response.status).to eq(409)
        # TODO: better nested errors
        expect(JSON.parse(response.body)).to match(
          "errors" => ["Statement items is invalid"],
          "token" => an_instance_of(String)
        )
      end
    end
  end

  context "when statement already exists" do
    let(:creator) { StatementCreator.new(user) }
    let(:statement) { creator.statement }
    before do
      creator.call(statement_params)
    end

    context "creating a duplicate statement" do
      it "409 with a description of the error" do
        expect {
          post '/v1/statements', params: { statement: statement_params, token: token }
        }.not_to change(Statement, :count)

        expect(response.status).to eq(409)
        expect(JSON.parse(response.body)).to match(
          "errors" => ["Year has already been taken"],
          "token" => an_instance_of(String)
        )
      end
    end

    context "retrieving an exiting statement" do
      it "returns statement data for the given year" do
        get '/v1/statements/2024', params: { token: token }

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to match(
          "statement" => {
            "year" => Date.today.year,
            "disposable_income" => 54400.0,
            "ie_rating" => "B"
          },
          "token" => an_instance_of(String)
        )
      end
    end
  end

  context "when statements exists for a different user" do
    let(:other_user) { User.create(email: 'other@test.com') }
    let(:creator) { StatementCreator.new(other_user) }
    let(:statement) { creator.statement }
    before do
      creator.call(statement_params)
    end

    context "retrieving an exiting statement" do
      it "404 with a description of the error" do
        get '/v1/statements/2024', params: { statement: statement_params, token: token }

        expect(response.status).to eq(404)
        expect(JSON.parse(response.body)).to match(
          "errors" => ["Statement not found"],
          "token" => an_instance_of(String)
        )
      end
    end
  end
end
