# frozen_string_literal: true

# UserClassesSubjects contoller for create and delete
class UserClassesSubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user, only: %i[create remove_user_classes_subjects]
  before_action :find_class, only: %i[create remove_user_classes_subjects]
  before_action :find_subject, only: %i[create remove_user_classes_subjects]
  before_action :class_has_the_subject?, only: %i[create]
  before_action :user_has_the_subject?, only: %i[create]
  before_action :find_user_class_subject, only: %i[remove_user_classes_subjects]

  def create
    return unless authorize :user_classes_subject, :create?

    begin
      rec = UserClassesSubject.new(user_id: @user.id, subject_id: @subject.id, teaching_class_id: @teaching_class.id)
      if rec.save
        render_success_response('Successfully updated the profile.', true)
      else
        render_failed_response(rec.errors[:user_id][0])
      end
    rescue Exception => e
      render_failed_response(e.message)
    end
  end

  def remove_user_classes_subjects
    return unless authorize :user_classes_subject, :remove_user_classes_subjects?

    begin
      UserClassesSubject.destroy(@user_classes_subject.id)
      render_success_response('Successfully updated the profile.', true)
    rescue ActiveRecord::RecordNotFound, ArgumentError, NoMethodError
      render_failed_response('Failed to update the profile.')
    end
  end

  private

  def find_user
    @user = User.find(params['user_classes_subject']['user_id'])
  rescue ActiveRecord::RecordNotFound
    render_failed_response("User record not found for ID #{params['user_classes_subject']['user_id']}")
  end

  def find_class
    @teaching_class = TeachingClass.find(params['user_classes_subject']['teaching_class_id'])
  rescue ActiveRecord::RecordNotFound
    render_failed_response("Class record not found for ID #{params['user_classes_subject']['teaching_class_id']}")
  end

  def find_subject
    @subject = Subject.find(params['user_classes_subject']['subject_id'])
  rescue ActiveRecord::RecordNotFound
    render_failed_response("Subject record not found for ID #{params['user_classes_subject']['subject_id']}")
  end

  def find_user_class_subject
    @user_classes_subject = UserClassesSubject.find_by(user_id: @user.id, subject_id: @subject.id,
                                                       teaching_class_id: @teaching_class.id)
  rescue ActiveRecord::RecordNotFound
    render_failed_response('Failed to find the record.')
  end

  def user_has_the_subject?
    return unless authorize :user_classes_subject, :create?

    unless @user.subject_ids.include?(@subject.id)
      render_failed_response("#{@subject.name} is not yet marked as teaching subject of #{@user.firstname}")
    end
  end

  def class_has_the_subject?
    return unless authorize :user_classes_subject, :create?

    unless @teaching_class.subject_ids.include?(@subject.id)
      render_failed_response("#{@subject.name} is not yet assigned to #{@teaching_class.name}")
    end
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
