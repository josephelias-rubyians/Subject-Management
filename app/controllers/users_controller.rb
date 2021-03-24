# frozen_string_literal: true

# Users contoller for list, update, destroy etc
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show update destroy update_password]

  def index
    @users = current_user
    @total_pages, @total_entries = 1, 1
    set_variables if current_user.admin?
    render json: {
      status: { code: 200, message: 'Success.' },
      meta: { total_pages: @total_pages, total_entries: @total_entries },
      data: UserSerializer.new(@users).serializable_hash[:data]
    }
  end

  def show
    if authorize @user
      render json: {
        status: { code: 200, message: 'Success.' },
        data: UserSerializer.new(@user).serializable_hash[:data][:attributes]
      }
    end
  end

  def update
    if authorize @user
      @user.update(user_params)
      render json: {
        status: { code: 200, message: 'Successfully updated the profile.' },
        data: UserSerializer.new(@user).serializable_hash[:data][:attributes]
      }
    end
  end

  def destroy
    if authorize @user
      @user.destroy
      render json: {
        message: 'Successfully deleted the profile.'
      }, status: 200
    end
  end

  def update_password
    if @user.valid_password?(params[:user][:current_password])
      if @user.update(update_password_params)
        continue_login
      else
        validation_failed_msg
      end
    else
      invalid_current_pswd_msg
    end
  end

  def continue_login
    bypass_sign_in(@user)
    render json: {
      message: 'Successfully changed the password.'
    }, status: 200
  end

  def validation_failed_msg
    render json: {
      error: 'Minimum 6 chars required/incorrect confirm password).'
    }, status: 400
  end

  def invalid_current_pswd_msg
    render json: {
      error: 'Please provide valid current password.'
    }, status: 400
  end

  private

  def user_params
    params.permit(:firstname, :lastname, :age, :avatar, :user_id)
  end

  def update_password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def set_user
    @user = User.find(params[:id])
  rescue Exception => e
    render json: {
      errors: {
        user: "Record not found for ID #{params[:id]}"
      }
    }, status: 400
  end

  def set_variables
    @users = User.paginate(page: params[:page], per_page: 10)
    @total_pages = @users.total_pages
    @total_entries = @users.total_entries
  end
end
