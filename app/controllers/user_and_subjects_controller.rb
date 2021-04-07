# frozen_string_literal: true

# UserAndSubjects contoller for create and delete
class UserAndSubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, only: %i[create remove_user_and_subjects]
  before_action :find_subjects, only: %i[create]
  before_action :find_user_and_subjects, only: %i[remove_user_and_subjects]

  def create
    return unless authorize @obj

    begin
      @user.subjects << @subjects
      render_success_response('Successfully updated the profile.', true)
    rescue Exception => e
      render_failed_response(e.message)
    end
  end

  def remove_user_and_subjects
    return unless authorize @obj

    begin
      @user_and_subjects.delete_all
      render_success_response('Successfully updated the profile.', true)
    rescue ActiveRecord::RecordNotFound
      render_failed_response('Failed to remove subjects.')
    end
  end

  private

  def find_user
    @user = User.find(params['user_and_subject']['user_id'])
    init_user_and_subject_obj
  rescue ActiveRecord::RecordNotFound
    render_failed_response("Record not found for ID #{params['user_and_subject']['user_id']}")
  end

  def find_subjects
    ids = params['user_and_subject']['subject_ids'].split(',').map(&:to_i)
    @subjects = Subject.find(ids)
  rescue ActiveRecord::RecordNotFound
    render_failed_response('Failed to find subjects')
  end

  def find_user_and_subjects
    ids = params['user_and_subject']['subject_ids'].split(',').map(&:to_i)
    @user_and_subjects = UserAndSubject.where(subject_id: ids, user_id: @user.id)
  rescue ActiveRecord::RecordNotFound
    render_failed_response('Failed to find user and subjects.')
  end

  def init_user_and_subject_obj
    # Just initializing for the purpose of authorization. We are not saving this to database.
    @obj = UserAndSubject.new(user_id: @user.id)
  end

  def render_failed_response(msg)
    render json: {
      error: msg
    }, status: 400
  end

  def render_success_response(msg, show_data)
    resp = {}
    resp['status'] = { code: 200, message: msg }
    resp['data'] = UserSerializer.new(@user).serializable_hash[:data] if show_data
    render json: resp
  end
end
