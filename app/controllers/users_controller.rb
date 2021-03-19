class UsersController < ApplicationController
	before_action :authenticate_user!
	before_action :set_user, only: [:show, :update, :destroy, :update_password]

	def index
		@users = current_user.admin? ? User.all : current_user
    render json: @users
  end

  def show
  	if (@user == current_user) && !(current_user.admin?)
  		render json: @user
  	elsif !(@user == current_user) && !(current_user.admin?)
  		render json: {error: "You are not allowed to view the profile."}, status: 400
  	else
  		render json: @user
  	end
  end

  def update
  	if (@user == current_user) && !(current_user.admin?)
  		@user.update(user_params)
  		render json: {message: "Successfully updated the profile."}, status: 200
  	elsif !(@user == current_user) && !(current_user.admin?)
  		render json: {error: "You are not allowed to update the profile."}, status: 400
  	else
  		@user.update(user_params)
  		render json: {message: "Successfully updated the profile."}, status: 200
  	end
  end

  def destroy
		if (@user == current_user) && !(current_user.admin?)
  		@user.destroy
  		render json: {message: "Successfully deleted the profile."}, status: 200
  	elsif !(@user == current_user) && !(current_user.admin?)
  		render json: {error: "You are not allowed to delete the profile."}, status: 400
  	else
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
