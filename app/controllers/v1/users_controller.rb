module V1
  class UsersController < ApplicationController
    def create
      @current_user = User.new(user_params)
      if @current_user.save
        render json: { token: generate_jwt }
      else
        render json: { errors: @current_user.errors.full_messages }, status: 409
        @current_user = nil
      end
    end

    def show
      @current_user = User.find_by(email: params[:email])

      if @current_user
        render json: { token: generate_jwt }
      else
        render json: { errors: ['User not found'] }, status: 409
      end
    end

    private

    def current_user
      @current_user
    end

    def user_params
      params.require(:user).permit(:email)
    end
  end
end
