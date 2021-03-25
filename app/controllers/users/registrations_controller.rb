# frozen_string_literal: true

# Registration contoller for signup
module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      @user = User.new(configure_sign_up_params)
      if @user.save
        sign_up(resource_name, resource)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    respond_to :json

    private

    def configure_sign_up_params
      params.require(:user).permit(:email, :password, :admin, :firstname, :lastname, :age, :avatar)
    end

    def respond_with(resource, _opts = {})
      render json: {
        status: { code: 200, message: 'Logged in successfully' },
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }
    end
  end
end
