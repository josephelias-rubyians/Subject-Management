class UsersController < ApplicationController
	before_action :authenticate_user!
	before_action :set_user, only: [:show, :update, :destroy, :update_password]

	def index
		@users = authorize current_user
    render json: @users
  end

  def show
    render json: @user if authorize @user
  end

  def update
    if authorize @user
  		@user.update(user_params)
  		render json: {message: "Successfully updated the profile."}, status: 200
    end
  end

  def destroy
    if authorize @user
      @user.destroy
      render json: {message: "Successfully deleted the profile."}, status: 200
    end
  end

	def update_password
		if @user.valid_password?(params[:user][:current_password])
			if @user.update(update_password_params)
				bypass_sign_in(@user)
				render json: {message: "Successfully changed the password."}, status: 200
			else
				render json: {error: "Minimum 6 chars required/incorrect confirm password)."}, status: 400
			end
		else
			render json: {error: "Please provide valid current password."}, status: 400
		end
	end


  private

  def user_params
    params.permit(:firstname, :lastname, :age, :avatar, :user_id)
  end

  def update_password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def set_user
  	begin
  		@user = User.find(params[:id])
  	rescue Exception => e
  		render json: {error: "Unable to find the profile."}, status: 400
  	end
  end

end
