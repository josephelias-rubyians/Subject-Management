# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  
  def create
    @user = User.new(configure_sign_up_params)  
    if @user.save
      begin
        UserMailer.registration_successful(@user).deliver
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError, SocketError => e
        Rails.logger.error("Failed to send mail...")
      end
      sign_up(resource_name, resource)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  respond_to :json

  private

  def configure_sign_up_params
    params.permit(:email, :password, :password_confirmation, :admin, :firstname, :lastname, :age, :avatar)
  end

  def respond_with(resource, _opts = {})
    render json: {
      status: {code: 200, message: 'Logged in successfully'},
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }
  end

end
