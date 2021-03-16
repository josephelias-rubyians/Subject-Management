# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  
  def create
    @user = User.new(configure_sign_up_params)  
    if @user.save
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  respond_to :json

  private

  def configure_sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :admin)
  end

  def respond_with(resource, _opts = {})
    render json: {
      status: {code: 200, message: 'Logged in successfully'},
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }
  end

end
