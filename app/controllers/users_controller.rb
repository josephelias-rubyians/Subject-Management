# frozen_string_literal: true

# Users contoller for list, update, destroy etc
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_record, only: %i[destroy]
  before_action :set_user, only: %i[show update update_password]

  def index
    @users = current_user
    @total_pages = 1
    @total_entries = 1
    set_variables if current_user.admin?
    render json: {
      status: { code: 200, message: 'Success.' },
      meta: { total_pages: @total_pages, total_entries: @total_entries },
      data: UserSerializer.new(@users).serializable_hash[:data]
    }
  end

  def show
    return unless authorize @user

    render_success_response('success.', true)
  end

  def update
    return unless authorize @user

    @user.update(user_params)
    render_success_response('Successfully updated the profile.', true)
  end

  def destroy
    return unless authorize @user

    @user.destroy
    render_success_response('Successfully deleted the profile.', false)
  end

  def update_password
    continue_update_pswd if authorize @user
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :age, :avatar, :password, :password_confirmation,
                                 :current_password)
  end

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_failed_response("Record not found for ID #{params[:id]}")
  end

  def find_record
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_success_response('Successfully deleted the profile.', false)
  end

  def set_variables
    @users = User.paginate(page: params[:page], per_page: 10)
    @total_pages = @users.total_pages
    @total_entries = @users.total_entries
  end

  def continue_update_pswd
    if @user.valid_password?(params[:user][:current_password])
      begin
        @user.update!(user_params)
        continue_login
      rescue ActiveRecord::RecordInvalid => e
        render_failed_response(e.message.gsub('Validation failed: ', ''))
      end
    else
      render_failed_response('Please provide valid current password.')
    end
  end

  def continue_login
    bypass_sign_in(@user)
    render_success_response('Successfully changed the password.', false)
  end

  def render_failed_response(msg)
    render json: {
      error: msg
    }, status: 400
  end

  def render_success_response(msg, show_data)
    resp = {}
    resp['status'] = { code: 200, message: msg }
    resp['data'] = UserSerializer.new(@user).serializable_hash[:data][:attributes] if show_data
    render json: resp
  end
end
