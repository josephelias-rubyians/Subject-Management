# frozen_string_literal: true

# SubjectAndClasses contoller for create and delete
class SubjectAndClassesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_class, only: %i[create remove_subject_and_classes]
  before_action :find_subjects, only: %i[create]
  before_action :find_class_and_subjects, only: %i[remove_subject_and_classes]

  def create
    return unless authorize :subject_and_class, :create?

    begin
      @teaching_class.subjects << @subjects
      render_success_response('Successfully updated the class.', true)
    rescue Exception => e
      render_failed_response(e.message)
    end
  end

  def remove_subject_and_classes
    return unless authorize :subject_and_class, :remove_subject_and_classes?

    begin
      @class_and_subjects.delete_all
      render_success_response('Successfully updated the class.', true)
    rescue ActiveRecord::RecordNotFound
      render_failed_response('Failed to remove subjects.')
    end
  end

  private

  def subject_and_class_params
    params.require(:subject_and_class).permit(:subject_id, :teaching_class_id)
  end

  def find_class
    @teaching_class = TeachingClass.find(params['subject_and_class']['teaching_class_id'])
  rescue ActiveRecord::RecordNotFound
    render_failed_response("Record not found for ID #{params['subject_and_class']['teaching_class_id']}")
  end

  def find_subjects
    ids = params['subject_and_class']['subject_ids'].split(',').map(&:to_i)
    @subjects = Subject.find(ids)
  rescue ActiveRecord::RecordNotFound
    render_failed_response('Failed to find subjects')
  end

  def find_class_and_subjects
    ids = params['subject_and_class']['subject_ids'].split(',').map(&:to_i)
    @class_and_subjects = SubAndClass.where(subject_id: ids, teaching_class_id: @teaching_class.id)
  rescue ActiveRecord::RecordNotFound
    render_failed_response('Failed to find class and subjects.')
  end

  def render_failed_response(msg)
    render json: {
      error: msg
    }, status: 400
  end

  def render_success_response(msg, show_data)
    resp = {}
    resp['status'] = { code: 200, message: msg }
    resp['data'] = TeachingClassSerializer.new(@teaching_class).serializable_hash[:data] if show_data
    render json: resp
  end
end
