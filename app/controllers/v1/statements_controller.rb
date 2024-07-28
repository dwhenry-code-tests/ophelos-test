module V1
  class StatementsController < ApplicationController
    # TODO: move this to shared base class
    before_action :authenticate_user!

    def create
      creator = StatementCreator.new(current_user)

      if creator.call(statement_params)
        render json: { statement: creator.statement.as_json, token: generate_jwt }
      else
        render json: { errors: creator.errors, token: generate_jwt }, status: 409
      end
    end

    def show
      statement = Statement.find(params[:id])

      if statement
        render json: { statement: statement.as_jsno, token: generate_jwt }
      else
        render json: { errors: ["Statement not found"], token: generate_jwt }, status: 404
      end
    end

    private

    def authenticate_user!
      user_id = begin
                  params[:token] && decode_token(params[:token]).first["user_id"]
                rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
                  nil
                end

      @current_user = User.find_by(id: user_id)

      render json: { errors: ['Valid token required'] }, status: 403 unless @current_user
    end

    def current_user
      @current_user
    end

    def statement_params
      params.require(:statement).permit(incomes: [:name, :amount], expenditures: [:name, :amount])
    end
  end
end